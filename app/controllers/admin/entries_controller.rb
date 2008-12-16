class Admin::EntriesController < ApplicationController
  layout 'admin'

  before_filter :load_project
  before_filter :load_bulletin_and_section

  before_filter(:except => [ :list, :show ]) do | c |
    c.check_role(:edit_entry, :back)
  end

  def index
    @entries = @section.entries.paginate :per_page => 20, :page => params[:page],
        :order => 'position'
  end
  
  def move_up
    @entry = @section.entries.find(params[:id])
    @entry.move_higher

    if params[:popup]
      redirect_to preview_edit_admin_project_bulletin_url(@project, @bulletin)
    else
      redirect_to :action => 'index'
    end
  end
  
  def move_down
    @entry = @section.entries.find(params[:id])
    @entry.move_lower
   
    if params[:popup]
      redirect_to preview_edit_admin_project_bulletin_url(@project, @bulletin)
    else
      redirect_to :action => 'index'
    end
  end

  def show
    @entry = @section.entries.find(params[:id])
  end

  def new
    @entry = @section.entries.build
    @entry.position = params[:position] if params[:position]
    if params[:popup]
      @popup_mode = true
      render :layout => 'admin_popup'
    end
  end

  def create
    @entry = @section.entries.build(params[:entry])
    
    if @entry.save
      if params[:popup]
        render :layout => 'admin_close_popup', :text => ''
      else
        flash[:notice] = _('Entry was successfully created.')
        redirect_to :action => 'index'
      end
    else
      render :action => 'new'
    end
  end

  def edit
    @entry = @section.entries.find(params[:id])
    if params[:popup]
      @popup_mode = true
      render :layout => 'admin_popup'
    end
  end

  def update
    @entry = @section.entries.find(params[:id])
    if @entry.update_attributes(params[:entry])
      if params[:popup]
        render :layout => 'admin_close_popup', :text => ''
      else
        flash[:notice] = _('Entry was successfully updated.')
        redirect_to :action => 'edit'
      end
    else
      render :action => 'edit'
    end
  end

  def destroy
    @section.entries.find(params[:id]).destroy

    if params[:popup]
      redirect_to preview_edit_admin_project_bulletin_url(@project, @bulletin)
    else
      redirect_to :action => 'index'
    end
  end

  protected

  def load_bulletin_and_section
    @bulletin = @project.bulletins.find(params[:bulletin_id])
    @section = @bulletin.sections.find(params[:section_id])
  end
end
