require File.dirname(__FILE__) + '/../test_helper'
require 'forward_controller'

# Re-raise errors caught by the controller.
class ForwardController; def rescue_action(e) raise e end; end

class ForwardControllerTest < Test::Unit::TestCase
  def setup
    @controller = ForwardController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
