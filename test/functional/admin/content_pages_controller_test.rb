require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/content_pages_controller'

# Re-raise errors caught by the controller.
class Admin::ContentPagesController; def rescue_action(e) raise e end; end

class Admin::ContentPagesControllerTest < Test::Unit::TestCase
  fixtures :admin_content_pages

  def setup
    @controller = Admin::ContentPagesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = content_pages(:first).id
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

    assert_not_nil assigns(:content_pages)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:content_page)
    assert assigns(:content_page).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:content_page)
  end

  def test_create
    num_content_pages = ContentPage.count

    post :create, :content_page => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_content_pages + 1, ContentPage.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:content_page)
    assert assigns(:content_page).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      ContentPage.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      ContentPage.find(@first_id)
    }
  end
end
