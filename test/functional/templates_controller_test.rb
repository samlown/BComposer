require File.dirname(__FILE__) + '/../test_helper'
require 'templates_controller'

# Re-raise errors caught by the controller.
class TemplatesController; def rescue_action(e) raise e end; end

class TemplatesControllerTest < Test::Unit::TestCase
  fixtures :templates

  def setup
    @controller = TemplatesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:templates)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:template)
    assert assigns(:template).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:template)
  end

  def test_create
    num_templates = Template.count

    post :create, :template => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_templates + 1, Template.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:template)
    assert assigns(:template).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Template.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Template.find(1)
    }
  end
end
