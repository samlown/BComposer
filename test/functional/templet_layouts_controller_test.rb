require File.dirname(__FILE__) + '/../test_helper'
require 'templet_layouts_controller'

# Re-raise errors caught by the controller.
class TempletLayoutsController; def rescue_action(e) raise e end; end

class TempletLayoutsControllerTest < Test::Unit::TestCase
  fixtures :templet_layouts

  def setup
    @controller = TempletLayoutsController.new
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

    assert_not_nil assigns(:templet_layouts)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:templet_layout)
    assert assigns(:templet_layout).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:templet_layout)
  end

  def test_create
    num_templet_layouts = TempletLayout.count

    post :create, :templet_layout => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_templet_layouts + 1, TempletLayout.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:templet_layout)
    assert assigns(:templet_layout).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil TempletLayout.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      TempletLayout.find(1)
    }
  end
end
