class Admin::ProjectsController < ApplicationController
  layout 'admin'

  skip_before_filter :require_project
  before_filter :require_project, :only => [ :show, :edit ]

  before_filter(:except => [:index, :show]) do | c |
    c.check_role(:edit_project, :controller=>'/admin/projects', :action => 'index')
  end
  before_filter :require_admin, :only => [ :new, :create, :destroy ]

  def index
    # if we have a project, make it nil!
    @project = nil

    if (current_user.projects.count == 1) 
      project = current_user.projects.find(:first)
      redirect_to admin_project_bulletins_url( :project_id => project.id )
      return
    elsif ((current_user.projects.count == 0) and (!current_user.is_admin?))
      # no user projects!
      flash[:error] = _("You do not belong to any projects! Please consult your administrator!")
      redirect_to :controller => '/admin/user', :action => 'logout'
      return 
    elsif (current_user.is_admin?)
      @projects = Project.paginate :page => params[:page], :per_page => 10
    else
      @projects = Project.paginate :page => params[:page], :per_page => 10,
         :include => :user_roles,
         :conditions => ['user_roles.user_id = ?', current_user.id]
    end 
  end

  def show
    @project = Project.find(params[:id]) unless @project
    redirect_to admin_project_bulletins_url(@project)
  end

  def new
    @project = Project.new
    @project.domain = request.protocol + request.host_with_port
  end

  def create
    @project = Project.new(params[:project])
    if @project.save
      flash[:notice] = _('Project was successfully created.')
      redirect_to admin_projects_url 
    else
      render :action => 'new'
    end
  end

  def edit
    if (! @project)
      @project = Project.find(params[:id])
    end
    @project.domain = request.protocol + request.host_with_port if (@project.domain.blank?)
  end

  def update
    if (! @project)
      @project = Project.find(params[:id])
    end
    if @project.update_attributes(params[:project])
      flash[:notice] = _('Project was successfully updated.')
      redirect_to admin_projects_url
    else
      render :action => 'edit'
    end
  end

  def destroy
    Project.find(params[:id]).destroy
    redirect_to admin_projects_url
  end
end
