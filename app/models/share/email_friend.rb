# Copyright (C) 2009 Pascal Rettig.

class Share::EmailFriend < DomainModel
  # belongs_to :share
  has_end_user :end_user_id, :name_column => :from_name
  belongs_to :content_node

  named_scope :between, lambda { |from, to| {:conditions => ['email_friends.sent_at >= ? AND email_friends.sent_at < ?', from, to]} }

  def self.emailed_scope(from, duration, opts={})
    scope = Share::EmailFriend.between(from, from+duration)
    scope = scope.scoped(:select => 'count(content_node_id) as hits, content_node_id as target_id', :group => 'target_id')
    scope
  end

  def self.emailed(from, duration, intervals, opts={})
    DomainLogGroup.stats('ContentNode', from, duration, intervals) do |from, duration|
      self.emailed_scope from, duration, opts
    end
  end

end
