

class Share::TellFeature < ParagraphFeature

  feature :share_tell_friend, :default_feature => <<-FEATURE
    <cms:sent>
      Your message has been sent
    </cms:sent>
    <cms:tell_friend>
      <cms:errors><div class='error'><cms:value/></div></cms:errors>
      <cms:to/>
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
      c.define_tag('tell_friend') do |tag|
        if data[:sent]
          nil
        else      
          tag.locals.form = data[:f]
          "<form action='' method='post' id='tell_friend_#{data[:paragraph].id}_form' enctype='multipart/form-data'>" + tag.expand + "</form>"
        end
      end
      c.define_expansion_tag('sent') { |tag| data[:sent] }
      c.define_form_error_tag('tell_friend:errors') 
      c.define_value_tag('tell_friend:options') do |tag|
          separator = tag.attr['separator'] || "<br/>"
          option_name = tag.attr['options'] ? tag.attr['options'].split(",") : nil
          if data[:message].send_type != 'select'
            output = ''
            opts = data[:options].options.select { |e| !e.blank? }
            data[:options].class.options_select_options.each_with_index do |opt,idx|
              if opts.include?(opt[1]) && !opt.blank?
                onclick = opts.collect do |sel_opt|
                    "document.getElementById('tell_friend_#{data[:paragraph].id}_#{sel_opt}').style.display='#{sel_opt == opt[1] ? '' : 'none' }'; " 
                  end.join(" ")
                onclick += "document.getElementById('tell_friend_#{data[:paragraph].id}_send_type').value = '#{opt[1]}';"
                output += "<a href='javascript:void(0);' onclick=\"#{onclick}\">#{h option_name ? option_name[idx] : opt[0]}</a>"
                if opt[1] != opts.last
                  output += separator
                end
              end
            end
            output
          else 
            nil
          end
        end
        
        c.link_tag('tell_friend:plaxo') do |t|
          { :href => 'javascript:void(0);',
            :onclick => "showPlaxoABChooser('tell_friend_#{data[:paragraph].id}_manual_to', '/website/share/tell/plaxo_import'); return false;"
          }
        end
        
        c.define_tag('tell_friend:to') { |tag| data[:to_html] }
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
