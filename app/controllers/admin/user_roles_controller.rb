class Admin::UserRolesController < ApplicationController

  layout 'admin'

  before_filter(:except => [:list]) do | c |
    c.check_role(:edit_project, :controller=>'projects', :action => 'list')
  end

  def index
    @user_roles = @project.user_roles.paginate :per_page => 20, :page => params[:page]

  end

  def show
    @user_role = @project.user_roles.find(params[:id])
  end

  #def new
  #  @user_role = UserRole.new
  #end

  #def create
  #  @user_role = UserRole.new(params[:user_role])
  #  if @user_role.save
  #    flash[:notice] = 'UserRole was successfully created.'
  #    redirect_to :action => 'list'
  #  else
  #    render :action => 'new'
  #  end
  #end

  def edit
    @user_role = @project.user_roles.find(params[:id])
  end

  def update
    @user_role = @project.user_roles.find(params[:id])
    if @user_role.update_attributes(params[:user_role])
      flash[:notice] = 'User Role was successfully updated.'
    end
    render :action => 'edit'
  end

  #def destroy
  #  UserRole.find(params[:id]).destroy
  #  redirect_to :action => 'list'
  #end
end
