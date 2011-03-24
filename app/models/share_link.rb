
class ShareLink < DomainModel

  validates_uniqueness_of :identifier_hash

  before_create :generate_identifier_hash
  belongs_to :end_user
  has_many :share_visitors

  def self.fetch(user)
    return nil if user.new_record?
    link = self.find_or_create_by_end_user_id(user.id)
    # Hack in case of a collision
    link = self.find_or_create_by_end_user_id(user.id) if link.new_record?
    link
  end

  def link(url)
    Configuration.domain_link(url.to_s + "?_source=" + self.identifier_hash.to_s);
    
  end

  def track(visitor_id,session_id)
    visitor = self.share_visitors.create(:domain_log_visitor_id => visitor_id,
                               :domain_log_session_id => session_id)
    ShareLink.update_all("visitors = visitors + 1", :id => self.id) if !visitor.new_record?

    visitor
  end

  def users
    EndUser.find(:all,:conditions => { :source_user_id => self.end_user_id }, :order => 'created_at DESC' )
  end

  protected

  def generate_identifier_hash 
    self.identifier_hash = self.class.generate_hash[0..16]
  end

end
