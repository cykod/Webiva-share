

class Share::SourceLinkHandler

  def initialize(ctrl)
    @ctrl = ctrl
  end

  def post_process(output)
    if @ctrl.params["_source"] || @ctrl.params['fb_ref']
      link = ShareLink.find_by_identifier_hash(@ctrl.params["_source"] || @ctrl.params['fb_ref'])
      if link && @ctrl.myself.new_record? && !@ctrl.session['share_visitor_id']
        

        visitor = @ctrl.session[:domain_log_visitor]
        session = @ctrl.session[:domain_log_session]

        tracking = link.track(visitor && visitor[:id], session && session[:id])

        if tracking
          @ctrl.myself.source_user_id = link.end_user_id
          @ctrl.session['share_visitor_id'] = tracking.id
        else
          @ctrl.session['share_visitor_id'] = 'Existing'
        end
      end
    end
    true
  end

end
