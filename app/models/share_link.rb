
class ShareLink < DomainModel

  validates_uniqueness_of :identifier_hash

  before_create :generate_identifier_hash
  belongs_to :end_user

  def self.fetch(user)
    link = self.find_or_create_by_end_user_id(user.id)
    # Hack in case of a collision
    link = self.find_or_create_by_end_user_id(user.id) if link.new_record?
    link
  end

  def link(url)
    Configuration.domain_link(url.to_s + "?_source=" + self.identifier_hash.to_s);
    
  end

  protected

  def generate_identifier_hash 
    self.identifier_hash = self.class.generate_hash[0..16]
  end

end
