require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/recipient_meta_options_controller'

# Re-raise errors caught by the controller.
class Admin::RecipientMetaOptionsController; def rescue_action(e) raise e end; end

class Admin::RecipientMetaOptionsControllerTest < Test::Unit::TestCase
  fixtures :recipient_meta_options

  def setup
    @controller = Admin::RecipientMetaOptionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = recipient_meta_options(:first).id
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

    assert_not_nil assigns(:recipient_meta_options)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:recipient_meta_option)
    assert assigns(:recipient_meta_option).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:recipient_meta_option)
  end

  def test_create
    num_recipient_meta_options = RecipientMetaOption.count

    post :create, :recipient_meta_option => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_recipient_meta_options + 1, RecipientMetaOption.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:recipient_meta_option)
    assert assigns(:recipient_meta_option).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      RecipientMetaOption.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      RecipientMetaOption.find(@first_id)
    }
  end
end
