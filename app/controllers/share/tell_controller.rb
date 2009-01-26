
class Share::TellController < ParagraphController 


  editor_header "Share Paragraphs"
  editor_for :tell_friend, :name => 'Tell a friend Paragraph', :features => [:share_tell_friend], :inputs => { :variables => [ [ :vars, 'Invite Variables', :variables ], [:target, "Invite Target", :target] ] }
  
  class TellFriendOptions  < HashModel
    attributes :options => [ 'manual','import','upload'], :email_template_id => nil, :success_page_id => nil, :default_subject => nil, :default_message => nil, :show => 'both', :email_from => nil, :share_level => 'low'
    
    has_options :share_level, ['low','medium','high']
    validates_presence_of :options
    
    integer_options :success_page_id,:email_template_id
        
    has_options :options, [['Enter Email Address','manual'],['Import from Email','import'],['Upload a File','upload']]
  end

end
