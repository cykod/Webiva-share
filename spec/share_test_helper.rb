
class TestTarget
  attr_accessor :id
end

module ShareTestHelper

  def create_end_user(email='test@webiva.com', options={:first_name => 'Test', :last_name => 'User'})
    EndUser.push_target(email, options)
  end

  def create_client_user(email='test@webiva.com', options={})
    user = EndUser.push_target(email, options)
    user.user_class = UserClass.client_user_class
    user.client_user_id = 1
    user
  end


  def missing_subject(options={})
                     
   Share::TellFriendMessage.new({:send_type => 'manual', :subject => nil, :manual_to => 'admin@cykod.com', :message => 'test message'})  

  end
  def missing_message(options={})
    Share::TellFriendMessage.new({:send_type => 'manual', :subject => 'test subject', :manual_to => 'admin@cykod.com', :message => nil})
    
  end
  def create_message(options={})
    Share::TellFriendMessage.new({:send_type => 'manual', :subject => 'test subject', :manual_to => 'admin@cykod.com', :message => 'test message'}.merge(options))
  end
  def stored_email_friends
    @end_user = create_end_user
    
    Share::EmailFriend.create(:end_user_id => @end_user.id,
                              :from_name => @end_user.full_name,
                              :to_email => "daffy@cykod.com",
                              :message => "message body", 
                              :sent_at => Time.now,
                              :ip_address => request.remote_ip, 
                              :session => session.session_id, 
                              :site_url => page_path)

  end
 
end
