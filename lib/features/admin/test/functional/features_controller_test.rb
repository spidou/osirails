require 'test_helper'
require File.dirname(__FILE__) + '/../admin_test'

require 'features_controller'

# re-raise errors caught by the controller.
class FeaturesController; def rescue_action(e) raise e end; end

class FeaturesControllerTest < ActionController::TestCase
  fixtures :features
  
  # assert_valid_markup :index, :but_first => :login
  
  def setup
    @controller = FeaturesController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end
  
  def test_index
    get :index
    assert_routing "features", {:controller => "features", :action => "index"}
  end
end