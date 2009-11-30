require 'blackbook'
require 'fileutils'


class Share::TellRenderer < ParagraphRenderer


  features '/share/tell_feature'
  
  
  paragraph :tell_friend
  
  
  def tell_friend
    @options = paragraph_options(:tell_friend)
    
    
    if @options.plaxo_import
      require_js((request.ssl? ? 'https' : 'http')  + '://www.plaxo.com/css/m/js/util.js')
      require_js((request.ssl? ? 'https' : 'http')  + '://www.plaxo.com/css/m/js/basic.js')
      require_js((request.ssl? ? 'https' : 'http')  + '://www.plaxo.com/css/m/js/abc_launcher.js')
    end

    if params["tell_friend_#{paragraph.id}"]
      handle_image_upload(params["tell_friend_#{paragraph.id}"],:upload_file_id, :location => Configuration.options.user_image_folder)
    end
    
    @message = Share::TellFriendMessage.new(params["tell_friend_#{paragraph.id}"])
    
    
    if !@limit && request.post? && params["tell_friend_#{paragraph.id}"] 
      if @message.send_type == 'upload' 
        @message.process_upload
      elsif @message.send_type == 'import'
        if !params["tell_friend_#{paragraph.id}"]['import_email'].blank?
          @message.process_import
        else
         @message.errors.add_to_base('Please enter an email address')
        end
      else
        @message.skip_subject = true if @options.show != 'both'
        @message.skip_message = true if @options.show == 'none'
        @message.valid?
        self.check_email_limit!
        # Send the message
        if @message.errors.length == 0
        
          if @options.email_template_id.to_i > 0  && @mail_template = MailTemplate.find_by_id(@options.email_template_id.to_i)
            @mail_template.replace_image_sources
            @mail_template.replace_link_hrefs
            
            sender_name = myself.id.blank? ? @message.name : myself.name 
            
            @message.emails.each do |email|
              vars = { :sender_name => h(sender_name), :message =>@mail_template.is_text ? h(@message.message) : simple_format(h(@message.message)),  :subject => @message.subject }
              
             connection_type,conn_data = page_connection(:variables)
              if connection_type == :vars
                vars.merge!(conn_data)
              elsif connection_type == :target
                if conn_data.respond_to?(:share_variables)
                 vars.merge!(conn_data.share_variables)                
                end
              end
                    
              vars['system:from'] = DomainModel.variable_replace(@options.email_from,vars) unless @options.email_from.blank?
              
              MailTemplateMailer.deliver_to_address(email,@mail_template,vars )
              ef = EmailFriend.create(:end_user_id => myself.id,:from_name => sender_name,:to_email => email,:message => h(@message.message), :sent_at => Time.now,:ip_address => request.remote_ip, :session => session.session_id, :site_url => page_path)

              if connection_type == :target && conn_data.respond_to?(:share_notification)
                targs = ef.attributes
                targs['share_level'] = @options.share_level
                conn_data.share_notification(targs)
              end
            end
            

            if paragraph.update_action_count > 0
              paragraph.run_triggered_actions({ :sender_name => h(sender_name), :message => h(@message.message), :recipients => @message.emails.join("<br/>") },'action',myself)
            end

            if @options.success_page_id.to_i > 0
              redirect_paragraph :site_node => @options.success_page_id.to_i
            else
              flash[:sent_to_a_friend] = true
              redirect_paragraph :page
            end
            return
         else
           @message.errors.add_to_base('Configuration Error, please contact the system administrator')
         end        
       end
      end
    elsif params[:partial_form]
      @message.subject = params[:partial_form][:subject] ? params[:partial_form][:subject] : @options.default_subject
      @message.message = params[:partial_form][:message] ? params[:partial_form][:message] : @options.default_message
    else
      @message.subject = @options.default_subject
      @message.message = @options.default_message
      
      connection_type,conn_data = page_connection(:variables)
      if connection_type == :vars
        @message.message = variable_replace(@message.message,conn_data)
      end
      
    end


    connection_type,conn_data = page_connection(:variables)
    if connection_type && conn_data.blank?
      render_paragraph :text => ''
      return    
    end
    
    
    to_html = render_to_string :partial => '/share/tell/tell_friend_to', :locals => { :message => @message, :options => @options, :paragraph => paragraph }
  
    data = { :message => @message, :options => @options, :paragraph => paragraph, :renderer => self, :to_html => to_html, :sent => flash[:sent_to_a_friend] }
    
    render_paragraph :text => share_tell_friend_feature(data)

  end
  

  
  def check_email_limit!
  
    email_limit = (@options.email_limit || 20).to_i
    ip_limit = (@options.ip_limit || 100).to_i
    
    if myself.id 
      sent_emails = EmailFriend.count(:all,:conditions => ['end_user_id=? AND sent_at >= ?',myself.id,24.hours.ago])
      sent_emails_ip = EmailFriend.count(:all,:conditions => ['ip_address=? AND sent_at >= ?',request.remote_ip,24.hours.ago])
    else
      sent_emails = EmailFriend.count(:all, :conditions => ['ip_address = ? AND sent_at >= ?',request.remote_ip,24.hours.ago])
    end  
      
    if myself.id && sent_emails >= email_limit
      @limit = true
      @message.errors.add_to_base('There is a limit of %s emails per user per 24 hours' / email_limit.to_s)
      @message.errors.add_to_base('There is a limit of %s emails per ip address per 24 hours' / ip_limit.to_s) if sent_emails_ip >= ip_limit
    elsif sent_emails >= email_limit
      @message.errors.add_to_base('There is a limit of %s emails per unregistered user per 24 hours' / email_limit.to_s)
      @limit = true 
    end    
  end
    
      

end
