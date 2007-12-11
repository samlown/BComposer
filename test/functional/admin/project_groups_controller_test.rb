require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/project_groups_controller'

# Re-raise errors caught by the controller.
class Admin::ProjectGroupsController; def rescue_action(e) raise e end; end

class Admin::ProjectGroupsControllerTest < Test::Unit::TestCase
  fixtures :admin_project_groups

  def setup
    @controller = Admin::ProjectGroupsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = project_groups(:first).id
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

    assert_not_nil assigns(:project_groups)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:project_group)
    assert assigns(:project_group).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:project_group)
  end

  def test_create
    num_project_groups = ProjectGroup.count

    post :create, :project_group => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_project_groups + 1, ProjectGroup.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:project_group)
    assert assigns(:project_group).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      ProjectGroup.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      ProjectGroup.find(@first_id)
    }
  end
end
