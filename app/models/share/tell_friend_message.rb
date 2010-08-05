
class Share::TellFriendMessage < HashModel
  attributes :to => '', :subject => '',:message => '',:send_type => 'manual', :manual_to => nil,:name => nil, :first_name => nil, :last_name => nil, :email => nil, :require_email => false

  validates_presence_of :send_type
  
  include WebivaCaptcha::ModelSupport

  attr_accessor :skip_subject, :skip_message
  
  def validate
    errors.add_to_base("Please enter a subject") if self.subject.blank? && !self.skip_subject   
    errors.add_to_base("Please enter a message") if self.message.blank? && !self.skip_message
    @emails = generate_manual_email_list 
    self.errors.add_to_base("Please enter one or more email addresses") if @emails.length == 0
    errors.add_to_base("Please enter your email") if self.email.blank? && self.require_email

    self.name = self.first_name.to_s + " " + self.last_name.to_s if !self.first_name.blank? || !self.last_name.blank?
  
  end
  
  attr_reader :emails
  
  def generate_manual_email_list
    email_list = self.manual_to.to_s.split(/\n|,/).collect { |eml| eml.strip }.select { |eml| !eml.blank? }.uniq
    email_list.select { |eml| !eml.blank? }.each do  |email|
      if email =~ /\<([^\>]+)\>/
        errors.add_to_base("'#{h(email.to_s)}' is not a valid email") if !($1 =~ RFC822::EmailAddress)

      elsif !(email =~ RFC822::EmailAddress)
        errors.add_to_base("'#{email.to_s}' is not a valid email")
      end
    end
    email_list      
  end  
end  

