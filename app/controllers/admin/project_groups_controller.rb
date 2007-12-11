class Admin::ProjectGroupsController < ApplicationController

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
    @project_group_pages, @project_groups = paginate :project_groups, :per_page => 10
  end

  def show
    @project_group = ProjectGroup.find(params[:id])
  end

  def new
    @project_group = ProjectGroup.new
  end

  def create
    @project_group = ProjectGroup.new(params[:project_group])
    if @project_group.save
      flash[:notice] = 'ProjectGroup was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @project_group = ProjectGroup.find(params[:id])
  end

  def update
    @project_group = ProjectGroup.find(params[:id])
    if @project_group.update_attributes(params[:project_group])
      flash[:notice] = 'ProjectGroup was successfully updated.'
      redirect_to :action => 'show', :id => @project_group
    else
      render :action => 'edit'
    end
  end

  def destroy
    ProjectGroup.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
