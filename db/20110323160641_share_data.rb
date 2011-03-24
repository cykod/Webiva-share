class ShareData < ActiveRecord::Migration
  def self.up
    create_table :share_links do |t|
      t.integer :end_user_id
      t.string :identifier_hash
      t.timestamps
    end

    add_index :share_links, :end_user_id, :name => 'user_index'
    add_index :share_links, :identifier_hash, :name => 'identifier'


    create_table :share_visitors do |t|
      t.integer :share_link_id
      t.integer :end_user_id
      t.integer :domain_log_visitor_id 
      t.integer :domain_log_session_id

      t.timestamps
    end

    add_index :share_visitors, :end_user_id, :name => 'user_index'
  end

  def self.down

    drop_table :share_links
    drop_table :share_visitors
  end
end
