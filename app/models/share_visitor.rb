


class ShareVisitor < DomainModel
  validates_uniqueness_of :domain_log_visitor_id
  belongs_to :share_link

  belongs_to :domain_log_visitor
  belongs_to :domain_log_session

  belongs_to :end_user
end
