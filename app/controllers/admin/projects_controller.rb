class Admin::ProjectsController < ApplicationController
  layout 'admin'

  skip_before_filter :require_project
  before_filter :require_project, :only => [ :show, :edit ]

  before_filter(:except => [:list, :show]) do | c |
    c.check_role(:edit_project, :controller=>'/admin/projects', :action => 'list', :project_name => nil)
  end
  before_filter :require_admin, :only => [ :new, :create, :destroy ]

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def index
    list
    render :action => 'list'
  end

  def list
    # if we have a project, make it nil!
    @project = nil

    if (current_user.projects.count == 1) 
      project = current_user.projects.find(:first)
      redirect_to :controller => 'bulletins', :action => 'list', :project_name => project.name
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
    redirect_to :controller => 'bulletins', :action => 'list'
  end

  def new
    @project = Project.new
    @project.domain = request.protocol + request.host_with_port
  end

  def create
    @project = Project.new(params[:project])
    @project.date_updated = Time.now
    if @project.save
      flash[:notice] = _('Project was successfully created.')
      redirect_to :action => 'list'
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
    @project.date_updated = Time.now
    if @project.update_attributes(params[:project])
      flash[:notice] = _('Project was successfully updated.')
      redirect_to :action => 'list'
    else
      render :action => 'edit'
    end
  end

  def destroy
    Project.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
