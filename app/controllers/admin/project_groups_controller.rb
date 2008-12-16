class Admin::ProjectGroupsController < ApplicationController

  layout 'admin'

  skip_before_filter :require_project
  before_filter :require_admin
  
  def index
    @project_groups = ProjectGroup.paginate :per_page => 20, :page => params[:page]
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
      redirect_to :action => 'index'
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
      redirect_to admin_project_group_url(@project_group)
    else
      render :action => 'edit'
    end
  end

  def destroy
    ProjectGroup.find(params[:id]).destroy
    redirect_to admin_project_groups_url
  end
end
