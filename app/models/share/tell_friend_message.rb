
class Share::TellFriendMessage < HashModel
  attributes :to => '', :subject => '',:message => '',:send_type => 'manual', :manual_to => nil, :emails_select => [], :import_email => nil, :import_provider => nil, :import_password => nil, :selected_email => [], :import_emails => [], :upload_file_id => nil, :name => nil
  
  validates_presence_of :send_type
  
   @@field_matching = {
    'first name' => 'first_name',
    'last name' => 'last_name',
    'middle name' => 'middle_name',
    'e-mail address' => 'email',
    'e-mail' => 'email',
    'email' => 'email',
    'home postal code' => 'zip',
    'home phone' => 'phone_number'
  }
  
  attr_accessor :skip_subject, :skip_message
  
  def validate
    errors.add_to_base("Please enter a subject") if self.subject.blank? && !self.skip_subject   
    errors.add_to_base("Please enter a message") if self.message.blank? && !self.skip_message
  
    case self.send_type
    when 'manual':
      @emails = generate_manual_email_list 
      self.errors.add_to_base("Please enter one or more email addresses") if @emails.length == 0
    when 'select':
      @emails = selected_email
      self.errors.add_to_base("Please select one or more email addresses") if @emails.length == 0
    else 
      self.errors.add_to_base("Please select who you would like to send the message to")
    end
  end
  
  attr_reader :emails
  
  def generate_manual_email_list
    email_list = self.manual_to.split(/\n|,/).collect { |eml| eml.strip }.select { |eml| !eml.blank? }.uniq
    email_list.select { |eml| !eml.blank? }.each do  |email|
      if email =~ /\<([^\>]+)\>/
        errors.add_to_base("'#{h(email.to_s)}' is not a valid email") if !($1 =~ RFC822::EmailAddress)
      elsif !(email =~ RFC822::EmailAddress)
        errors.add_to_base("'#{email.to_s}' is not a valid email")
      end
    end
    email_list      
  end
  
  def process_upload
    if !self.upload_file_id
      self.errors.add_to_base('Please select a file to upload')
      return
    end
    uploaded_file = DomainFile.find_by_id(self.upload_file_id)
    
    begin
      email_list = self.import_csv(uploaded_file)
      uploaded_file.destroy

      import_emails = email_list.collect { |eml| validate_import_email(eml,nil) }.compact

      if import_emails.length == 0
        errors.add_to_base("No valid emails found") 
      else
        self.send_type = 'select'
      end
    rescue Exception => e
       errors.add_to_base("Invalid file format - please verify the uploaded file is a CSV file.") 
    end
      

  end
  
  def  process_import
     begin
      import_emails = Blackbook.get :username => self.import_email.to_s + "@" +  self.import_provider.to_s, 
                                                 :password => self.import_password.to_s
      self.import_emails = import_emails.collect { |eml| import_contact(eml,self.import_provider) }.compact
      
      if import_emails.length == 0
        errors.add_to_base("No valid emails found") 
      else
        self.send_type = 'select'
      end
    rescue Blackbook::BadCredentialsError
     self.errors.add_to_base("Email credentials were not accepted")
    rescue Exception => e
     self.errors.add_to_base("Could not download email addresses please try again later")
    end        
  end
  
  

  protected
  
  
  def import_csv(df)
    begin
      reader = CSV.open(df.filename,'r')
      title_row = reader.shift
      
      # Create a list of matched fields from the title row
      # to generate an easy import
      matched_fields = []
      title_row.each_with_index do |fld,index|
        if @@field_matching[fld.downcase]
          matched_fields << [ index, @@field_matching[fld.downcase] ]
        end
      end
      
      contacts = []
      reader.each do |row|
        email = {}
        matched_fields.each do |fld|
          email[fld[1]] = row[fld[0]] 
        end
        if email[:first_name] || email[:last_name]
          email = [ email[:first_name], email[:last_name] ].compact.join(" ") + "<#{email[:email]}>"
        else
          email = email[:email]
        end
        
        contacts << email unless email.blank?
      end
      reader.close
      return contacts
    rescue Exception => e
      return nil
    end  
  
  end
  
  def import_contact(data,provider)
    email = {}
    
    case provider
    when 'gmail.com': 
        email = import_gmail_contact(data)
    when 'aol.com': 
      email = import_aol_contact(data)
    else 
      email = import_generic_contact(data)
    end
    
     if email[:first_name] || email[:last_name]
      email = [ email[:first_name], email[:last_name] ].compact.join(" ") + " <#{email[:email]}>"
     else
      email = email[:email]
     end
     
     validate_import_email(email)
    
  end  
  
  
  def validate_import_email(email)
    if email =~ /\<([^\>]+)\>/
      if $1 =~ RFC822::EmailAddress
        return email
      end
    elsif (email =~ RFC822::EmailAddress)
      return email
    end
    return nil
  end
  
  
  def import_gmail_contact(data)
    name = data[:name].strip.split(" ")
    info = data[:email]
    inf = {}
    # Ugly regexp to pull in extra info from BlackBook import
    # Eg: [{:name=>"Pascal Rettig", :email=>"pascal@rettig.org<span class=\"n\"> - (617)555-1212, 123 Elm St.</span>"}]
    if info =~ /^(.*)\<span[^>]*\>(.*)\<\/span\>$/
      inf[:email] = $1
      if $2 =~  /^ \- (.*?)(,(.*))$/
        phone_test = $1
        adr_test =$2
        if phone_test =~ /^1{0,1}\({0,1}([2-9][0-9]{2})\){0,1}\s*[\.-]{0,1}([0-9]{3})\s*[\.-]{0,1}([0-9]{4})$/
          inf[:phone] = phone_test
          if !adr_test.blank?
            zip_test = adr_test.split[-1]
            if zip_test =~ /^[0-9]+$/
              inf[:zip] = zip_test
            end
          end
        end
      end
    else
      inf[:email] = data[:email]
    end
  
    return { :first_name => name.length > 1 ? name[0] : nil,
                      :last_name => name[-1],
                      :email => inf[:email] }
  
  end

  
  def import_aol_contact(data)
    { :email => data[:email] }
  end
  

  
  def import_generic_contact(data)
    return {} unless data
    if data[:name]
      name = data[:name].to_s.strip.split(" ")
    else
      name = []
    end
        
    { :first_name => name.length > 1 ? name[0] : nil,
      :last_name => name[-1],
      :email => data[:email] }
  end
    
end  

