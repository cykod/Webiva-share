

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
      First Name: <cms:first_name/> Last Name: <cms:last_name/><br/>
      <cms:require_email>
         Your Email: <cms:email/>
      </cms:require_email>

      </cms:anonymous>
      <cms:captcha/>
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
             :html => { :id => "tell_friend_#{data[:paragraph].id}_form" },
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

        c.link_tag("tracking") { |t| data[:tracking_url] }
        c.value_tag('source') { |t| data[:tracking_source] }
        
        c.define_form_field_tag('tell_friend:to', :rows => '5', :control => 'text_area', :field => :manual_to) 
        c.define_form_field_tag('tell_friend:subject')
        c.define_form_field_tag('tell_friend:message',:control => 'text_area')
        
        c.define_expansion_tag('anonymous') { |tag| myself.id.blank? }
        c.define_form_field_tag('tell_friend:name')
        c.define_form_field_tag('tell_friend:first_name', :size => 15)
        c.define_form_field_tag('tell_friend:last_name', :size => 15)
        c.define_form_field_tag('tell_friend:email')
        c.expansion_tag('tell_friend:require_email') { |t| data[:options].require_email }

        c.captcha_tag('tell_friend:captcha') { |t| data[:captcha] if data[:options].captcha }

        c.define_button_tag('tell_friend:button')
        c.define_expansion_tag('cancel') { |tag| data[:message].send_type == 'select' }
        c.define_button_tag('tell_friend:cancel:button', :onclick => 'document.location=document.location; return false');

      c.expansion_tag('tell_friend:content') { |t| t.locals.content = data[:message].content_node }
      c.value_tag('tell_friend:content:id') { |t| t.locals.content.id }
      c.h_tag('tell_friend:content:title') { |t| t.locals.content.title }
      c.link_tag('tell_friend:content:content') { |t| t.locals.content.link }
    end
  end

  feature :share_tell_view_impact, :default_feature => <<-FEATURE
      <cms:visitors>
        <div>
          Total Visitors: <cms:count/> 
        </div>
        <cms:users>
         Who's Signed up:
         <ol>
            <cms:user><li><cms:name/></li></cms:user>
         </ol>
        </cms:users>
      </cms:visitors>
      <cms:no_visitors>

      </cms:no_visitors>
  FEATURE

  def share_tell_view_impact_feature(data)
    webiva_feature(:share_tell_view_impact,data) do |c|

      c.expansion_tag('visitors') { |t| data[:link].visitors > 0 }
      c.value_tag('visitors:count') { |t| data[:link].visitors }

      c.value_tag('emails') { |t| data[:link].emails }
      c.loop_tag('visitors:user','users') { |t| data[:link].users }
      c.user_details_tags('visitors:user')
    end
  end
  
  feature :share_tell_sources, :default_feature => <<-FEATURE
  <cms:sources>
  <h2>Sources</h2>
  <ul>
    <cms:source>
      <cms:user>
        <li><cms:name/></li>
      </cms:user>
    </cms:source>
  </ul>
  </cms:sources>
  FEATURE

  def share_tell_sources_feature(data)
    webiva_feature(:share_tell_sources, data) do |c|
      c.loop_tag('source') { |t| data[:sources] }
      c.user_tags('source:user') { |t| t.locals.user = t.locals.source }

      c.expansion_tag('reward') { |t| data[:options].handler }
      data[:options].features(c, data, 'reward')
    end
  end
end
