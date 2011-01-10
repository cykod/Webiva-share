
class Share::TellController < ParagraphController 
  
  editor_header "Share Paragraphs"
  editor_for :tell_friend, :name => 'Tell a friend Paragraph', :feature => :share_tell_friend,
             :inputs => { :variables => [[:vars, 'Invite Variables', :variables ],
                                         [:target, "Invite Target", :target]],
                          :content => [[:id, "Content ID", :path],
                                       [:content_identifier, 'Content ID', :content]]
                        }  
  
  user_actions :plaxo_import
  
  class TellFriendOptions  < HashModel
    attributes :email_template_id => nil, :email_limit => 20 ,:success_page_id => nil, :default_subject => nil, :default_message => nil, :show => 'both', :email_from => nil, :share_level => 'low', :plaxo_import => true,  :connect_to_people => false, :people_tags => '', :require_email => false, :captcha => false


    has_options :share_level, ['low','medium','high']
    validates_presence_of :email_template_id
    
    boolean_options :plaxo_import, :connect_to_people, :require_email, :captcha
    
    integer_options :email_template_id, :email_limit

    page_options :success_page_id
  end
  
  
  def tell_friend
    @options = TellFriendOptions.new(params[:tell_friend] || paragraph.data || {})
    return if handle_paragraph_update(@options)
  end
 

  def plaxo_import
    render :inline => '<html><head><script type="text/javascript" src="https://www.plaxo.com/ab_chooser/abc_comm.jsdyn"></script></head><body></body></html>'
  end  
end
