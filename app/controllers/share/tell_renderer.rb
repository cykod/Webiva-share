require 'fileutils'


class Share::TellRenderer < ParagraphRenderer


  features '/share/tell_feature'
  paragraph :tell_friend
  paragraph :view_impact
  paragraph :sources
  
  def tell_friend
    @captcha = WebivaCaptcha.new(self)
    @options = paragraph_options(:tell_friend)
    
    if @options.plaxo_import
      require_js((request.ssl? ? 'https' : 'http')  + '://www.plaxo.com/css/m/js/util.js')
      require_js((request.ssl? ? 'https' : 'http')  + '://www.plaxo.com/css/m/js/basic.js')
      require_js((request.ssl? ? 'https' : 'http')  + '://www.plaxo.com/css/m/js/abc_launcher.js')
    end

    generate_tracking_link(myself) if @options.tracking_link

    @message = Share::TellFriendMessage.new(params["tell_friend_#{paragraph.id}"] || params["tell_friend_submit"])
    @message.user = myself

    connection_type,conn_data = page_connection(:content)
    if connection_type
      @message.content_node_id = conn_data if connection_type == :id
      @message.content_node_id = conn_data[1] if connection_type == :content_identifier
      return render_paragraph :nothing => true if @message.content_node.nil?
    else
      @message.content_node_id = site_node.content_node.id if site_node.content_node
    end

    if !@limit && request.post? && (params["tell_friend_#{paragraph.id}"] || (!params["partial"] && params["tell_friend_submit"]))
      @message.skip_subject = true if @options.show != 'both'
      @message.skip_message = true if @options.show == 'none'
      @message.require_email = true if @options.require_email
      @captcha.validate_object(@message, :skip => ! @options.captcha)
      
      @message.valid?
      self.check_email_limit!
      # Send the message
      if @message.errors.length == 0

        if @options.connect_to_people && !@message.email.blank? && !myself.id

          people_attr = {}
          if !@message.first_name.blank? | !@message.last_name.blank?
            people_attr[:first_name] = @message.first_name
            people_attr[:last_name] = @message.last_name
          else
            people_attr[:name] = @message.name
          end

          
          @usr = EndUser.push_target(@message.email,people_attr,myself.anonymous_tracking_information)
          @usr.tag_names_add(@options.people_tags) if !@options.people_tags.blank?
          
          session[:captured_user_info] =  { :email => @usr.email, :first_name => @usr.first_name, :last_name => @usr.last_name }

          generate_tracking_link(@usr) if @options.tracking_link
        end

        if @options.email_template_id.to_i > 0  && @mail_template = MailTemplate.find_by_id(@options.email_template_id.to_i)
          @mail_template.replace_image_sources
          @mail_template.replace_link_hrefs

          sender_name = myself.id.blank? ? @message.name : myself.name 
          sender_email = myself.email.blank? ? @message.email : myself.email

          @message.emails.each do |email|
            vars = { :sender_name => h(sender_name), :sender_email => h(sender_email), :message =>@mail_template.is_text ? h(@message.message) : simple_format(h(@message.message)),  :subject => @message.subject, :tracking_url => @tracking_url }

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
            site_url = @message.content_node ? @message.content_node.link : page_path
            ef = Share::EmailFriend.create(:end_user_id => myself.id,:from_name => sender_name,:to_email => email,:message => h(@message.message), :sent_at => Time.now,:ip_address => request.remote_ip, :session => session.session_id, :site_url => site_url, :content_node_id => @message.content_node_id)

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
    
    data = { :message => @message,:paragraph => paragraph, :sent => flash[:sent_to_a_friend], :options => @options, :captcha => @captcha, :tracking_url => @tracking_url, :tracking_source => @tracking_source }
    
    render_paragraph :text => share_tell_friend_feature(data)

  end


  def view_impact

    return render_paragraph :text => 'Not Logged In' if !myself.id


    @link = ShareLink.fetch(myself)

    @myself = myself

    render_paragraph :feature => :share_tell_view_impact

  end

  def sources
    @options = paragraph_options :sources
    return render_paragraph :nothing => true unless myself.id
    
    if editor?
      @sources = EndUser.all :limit => 10
      render_paragraph :feature => :share_tell_sources
      return
    end

    @sources = EndUser.where(:source_user_id => myself.id).all
    @options.reward myself, @sources

    render_paragraph :feature => :share_tell_sources
  end


  def generate_tracking_link(user)
    # generate a tracking link
    if user.id
      @user_link = ShareLink.fetch(user) 
      @tracking_url = @user_link.link(@options.tracking_page_url)
      @tracking_source = @user_link.identifier_hash
    else
      @tracking_url = Configuration.domain_link(@options.tracking_page_url)
    end
  end
  
  
  def check_email_limit!
    email_limit = (@options.email_limit || 20).to_i
    ip_limit = (@options.ip_limit || 100).to_i
    
    if myself.id 
      sent_emails = Share::EmailFriend.count(:all,:conditions => ['end_user_id=? AND sent_at >= ?',myself.id,24.hours.ago])
      sent_emails_ip = Share::EmailFriend.count(:all,:conditions => ['ip_address=? AND sent_at >= ?',request.remote_ip,24.hours.ago])
    else
      sent_emails = Share::EmailFriend.count(:all, :conditions => ['ip_address = ? AND sent_at >= ?',request.remote_ip,24.hours.ago])
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
