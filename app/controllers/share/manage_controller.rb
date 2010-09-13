 class Share::ManageController < ModuleController
   
   component_info 'share'
   
   
   cms_admin_paths 'mail',
                  'Mail' => { :controller => '/mail_manager' },
                  'Tell-a-Friend' => {:action => 'tell_friends' }
   
   helper :active_tree

   
   permit "editor_share"

   active_table :email_friend_table, Share::EmailFriend,
   [ ActiveTable::IconHeader.new('',:width => 10),
     ActiveTable::StringHeader.new('from_name'),
     ActiveTable::StringHeader.new('end_users.email', :label => 'User'),
     ActiveTable::StringHeader.new('to_email'),
     ActiveTable::StringHeader.new('site_url'),
     ActiveTable::DateRangeHeader.new('sent_at')
   ]
   
   def tell_friends
     cms_page_path [ 'Mail'],'Tell-a-Friend'
     
     display_email_friend_table(false)
   end
   
   def display_email_friend_table(display = true)
     
     @tbl = email_friend_table_generate params, :order => 'sent_at DESC', :include => [ :end_user ]
     
     render :partial => 'email_friend_table' if display
     
   end
   
   def email_friend
     @entry = EmailFriend.find_by_id(params[:path][0])
     
     render :partial => 'email_friend'
   end
   
   active_table :email_friend_group_table, Share::EmailFriend,
   [ ActiveTable::StringHeader.new('site_url'),
     ActiveTable::NumberHeader.new('count'),
     ActiveTable::DateRangeHeader.new('sent_at')
   ]
   
   def page_statistics
     cms_page_path [ 'Mail','Tell-a-Friend'],'Page Statistics'
     
     display_email_friend_group_table(false)
     
   end
   
   def tell_friends_download_all
     @tbl = email_friend_table_generate params, :order => 'sent_at DESC', :include => [ :end_user ], :all => 1
    output = ''

     CSV::Writer.generate(output) do |csv|
       csv << [ 'From', 'Email','To','Site Url','Sent At' ]
       @tbl.data.each { |t|   csv << [ t.from_name,t.end_user ? t.end_user.email : nil,t.to_email,t.site_url,t.sent_at ]}
       
     end
     
     send_data(output,
               :stream => true,
               :type => "text/csv",
               :disposition => 'attachment',
               :filename => "send_to_friend_user_statistics.csv"
               )
     
   end
   def display_email_friend_group_table(display=true)
     
     @tbl =email_friend_group_table_generate params, :order => 'sent_at DESC', :group => 'site_url',:select => 'COUNT(*) as count, site_url,MAX(sent_at) as sent_max, MIN(sent_at) as sent_min', :count_by => 'site_url'
     
     render :partial => 'email_friend_group_table' if display
   end
   
  def view_email
    @email = Share::EmailFriend.find_by_id(params[:path][0])
    render :partial => 'email_friend'
  end
  def download_page_statistics_data
    @tbl = email_friend_group_table_generate params,:order => 'sent_at DESC', :group => 'site_url',:select => 'COUNT(*) as count, site_url,MAX(sent_at) as sent_max, MIN(sent_at) as sent_min', :count_by => 'site_url', :all => 1
    
    output = ''
    CSV::Writer.generate(output) do |csv|
      csv << [ 'Site Url', 'Count','Sent Between' ]    
      @tbl.data.each { |t|   csv << [ t.count,t.site_url,"#{t.sent_min ? Time.parse(t.sent_min).strftime(DEFAULT_DATE_FORMAT.t) : '-' } - #{t.sent_max ? Time.parse(t.sent_max).strftime(DEFAULT_DATE_FORMAT.t) : '-'}" ]}
        
      
    end
    
    send_data(output,
              :stream => true,
              :type => "text/csv",
              :disposition => 'attachment',
              :filename => "send_to_friend_page_statistics.csv"
              )
  end
  
  
end

