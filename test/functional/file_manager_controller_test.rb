require File.dirname(__FILE__) + '/../test_helper'
require 'file_manager_controller'

# Re-raise errors caught by the controller.
class FileManagerController; def rescue_action(e) raise e end; end

class FileManagerControllerTest < Test::Unit::TestCase
  def setup
    @controller = FileManagerController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
