

class Share::TellFeature < ParagraphFeature

  feature :share_tell_friend, :default_feature => <<-FEATURE
    <cms:sent>
      Your message has been sent
    </cms:sent>
    <cms:tell_friend>
      <cms:errors><div class='error'><cms:value/></div></cms:errors>
      Enter email addresses (one per line):
      <br />
      <cms:to/>
      <br />
      <cms:plaxo_link>Import from your address book</cms:plaxo_link><br/>
      Message subject:<br/>
      <cms:subject/><br/>
      Message:<br/>
      <cms:message/><br/>
      <cms:anonymous>
      Your Name: <cms:name/>
      </cms:anonymous>
      <cms:button>Send Message</cms:button>
    </cms:tell_friend>
  FEATURE
  
  
  def share_tell_friend_feature(data)
    webiva_feature(:share_tell_friend) do |c|
      c.form_for_tag('tell_friend', "tell_friend_#{paragraph.id}") do |tag|
        if data[:sent]
          nil
        else 
          {  :object => data[:message],
              :id => "tell_friend_#{data[:paragraph].id}_form",
             :code => "<script type='text/javascript'><!--function onABCommComplete() { }//--></script>"
          }
        end
      end
      c.define_expansion_tag('sent') { |tag| data[:sent] }
      c.define_form_error_tag('tell_friend:errors') 
            
        c.link_tag('tell_friend:plaxo') do |t|
          { :href => 'javascript:void(0);',
            :onclick => "showPlaxoABChooser('tell_friend_#{data[:paragraph].id}_manual_to', '/website/share/tell/plaxo_import'); return false;"
          }
        end
        
        c.define_form_field_tag('tell_friend:to', :rows => '5', :control => 'text_area', :field => :manual_to) 
        c.define_form_field_tag('tell_friend:subject')
        c.define_form_field_tag('tell_friend:message',:control => 'text_area')
        
        c.define_expansion_tag('anonymous') { |tag| myself.id.blank? }
        c.define_form_field_tag('tell_friend:name')
        
        c.define_button_tag('tell_friend:button')
        c.define_expansion_tag('cancel') { |tag| data[:message].send_type == 'select' }
        c.define_button_tag('tell_friend:cancel:button', :onclick => 'document.location=document.location; return false');
    end
  end
  
  
  
end
