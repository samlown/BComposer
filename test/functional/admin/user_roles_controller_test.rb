require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/user_roles_controller'

# Re-raise errors caught by the controller.
class Admin::UserRolesController; def rescue_action(e) raise e end; end

class Admin::UserRolesControllerTest < Test::Unit::TestCase
  fixtures :user_roles

  def setup
    @controller = Admin::UserRolesController.new
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

    assert_not_nil assigns(:user_roles)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:user_role)
    assert assigns(:user_role).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:user_role)
  end

  def test_create
    num_user_roles = UserRole.count

    post :create, :user_role => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_user_roles + 1, UserRole.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:user_role)
    assert assigns(:user_role).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil UserRole.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      UserRole.find(1)
    }
  end
end
