
class Share::TellController < ParagraphController 
  
  editor_header "Share Paragraphs"
  editor_for :tell_friend, :name => 'Tell a friend Paragraph', :feature => :share_tell_friend, :inputs => { :variables => [ [ :vars, 'Invite Variables', :variables ], [:target, "Invite Target", :target] ] }
  
  
  user_actions :plaxo_import
  
  class TellFriendOptions  < HashModel
    attributes :options => [ 'manual','import','upload'], :email_template_id => nil, :success_page_id => nil, :default_subject => nil, :default_message => nil, :show => 'both', :email_from => nil, :share_level => 'low', :plaxo_import => true
    
    has_options :share_level, ['low','medium','high']
    validates_presence_of :options
    
    
    boolean_options :plaxo_import
    
    integer_options :success_page_id,:email_template_id
        
    has_options :options, [['Enter Email Address','manual'],['Import from Email','import'],['Upload a File','upload']]
  end


  def tell_friend
    @options = TellFriendOptions.new(params[:tell_friend] || paragraph.data || {})
    return if handle_paragraph_update(@options)

  end
 

  def plaxo_import
    render :inline => '<html><head><script type="text/javascript" src="https://www.plaxo.com/ab_chooser/abc_comm.jsdyn"></script></head><body></body></html>'
  end  
end
