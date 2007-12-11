class Admin::UserRolesController < ApplicationController

  layout 'admin'

  before_filter(:except => [:list]) do | c |
    c.check_role(:edit_project, :controller=>'projects', :action => 'list')
  end


  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @user_role_pages, @user_roles = paginate :user_roles, :per_page => 20,
       :conditions => ['project_id = ?', @project.id]
  end

  def show
    @user_role = UserRole.find(params[:id])
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
    @user_role = UserRole.find(params[:id])
  end

  def update
    @user_role = UserRole.find(params[:id])
    if @user_role.update_attributes(params[:user_role])
      flash[:notice] = 'UserRole was successfully updated.'
    end
    render :action => 'edit'
  end

  #def destroy
  #  UserRole.find(params[:id]).destroy
  #  redirect_to :action => 'list'
  #end
end
