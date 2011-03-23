class ShareData < ActiveRecord::Migration
  def self.up
    create_table :share_links do |t|
      t.integer :end_user_id
      t.string :hash
      t.timestamps
    end


    create_table :share_visitors do |t|
      t.integer :share_link_id
      t.integer :end_user_id
      t.integer :domain_log_visitor_id 
      t.integer :domain_log_session_id

      t.timestamps
    end
  end

  def self.down

    drop_table :share_lnks
    drop_table :share_visitors
  end
end
