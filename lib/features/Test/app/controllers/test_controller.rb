# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.



class TestController < ActionController::Base
  def index
    render :text => "COUCOU"
    Document.can_list?(role)
    Document.can
end
end
