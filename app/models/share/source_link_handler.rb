

class SourceLinkHandler

  def initialize(ctrl)
    @ctrl = ctrl
  end

  def before_request
    if params["_source"]
      session[
    end
    true
  end

end
