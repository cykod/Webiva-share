class ContentNode < ActiveRecord::Migration
  def self.up
    add_column :email_friends, :content_node_id, :integer
  end

  def self.down
    drop_column :email_friends, :content_node_id
  end
end
