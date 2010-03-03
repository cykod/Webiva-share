 class EmailFriendTable < ActiveRecord::Migration


   def self.up
     if (self.table_exists?('email_friends'))
       say 'email_friends already exists'
     else
       create_table :email_friends do |t|
         t.integer :end_user_id
         t.string :from_name
         t.string :to_email
         t.string :page_title
         t.string :page_url
         t.text :message
         t.datetime :sent_at
         t.string :ip_address
         t.string :session
         t.string :site_url
       end
       
       add_index :email_friends, [ :sent_at, :ip_address ], :name => 'sent_ip'
       add_index :email_friends, [ :end_user_id, :sent_at ], :name => 'sending_user'
       add_index :email_friends, [ :site_url, :sent_at ], :name => 'url_index'
     end
   end
   
   def self.down
     drop_table :email_friends
   end
   
 end
