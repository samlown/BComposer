class Admin::UsersController < ApplicationController
  layout 'admin'

  skip_before_filter :require_project

  before_filter :require_admin

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @user_pages, @users = paginate :users, :per_page => 10
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
    @projects = Project.find(:all)
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      store_user_projects
      flash[:notice] = 'User was successfully created.'
      redirect_to :action => 'list'
    else
      @projects = Project.find(:all)
      render :action => 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
    @projects = Project.find(:all)
  end

  def update
    @user = User.find(params[:id])
    store_user_projects
    if (params[:user][:password] == '')
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end
    if @user.update_attributes(params[:user])
      flash[:notice] = 'User was successfully updated.'
      # redirect_to :action => 'show', :id => @user
    end
    @projects = Project.find(:all)
    render :action => 'edit'
  end

  def destroy
    user = User.find(params[:id])
    if (user.name == 'admin')
      flash[:notice] = "Cannot delete admin user!"
    else
      user.destroy
    end
    redirect_to :action => 'list'
  end
  
  private
  
  def store_user_projects
    return if ! params[:user_roles]

    roles = params[:user_roles]
    roles.collect do | id, state | 
      role = @user.user_roles.find_by_project_id(id)
      if (state == "1")
        @user.user_roles.create(:project_id => id) if (! role)
      else
        @user.user_roles.delete(role) if (role)
      end
    end
  end

end
