class Admin::SectionsController < ApplicationController
  layout 'admin'

  before_filter :load_project

  before_filter :load_bulletin

  before_filter(:except => [ :index, :show ]) do | c |
    c.check_role(:edit_section, :back)
  end

  def index
    @sections = @bulletin.sections.paginate :per_page => 10, :page => params[:page]
  end

  def show
    @section = @bulletin.sections.find(params[:id])
  end

  def new 
    @section = @bulletin.sections.build
  end

  def create
    @section = @bulletin.sections.build(params[:section])
    if @section.save
      flash[:notice] = _('Section was successfully created.')
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def edit
    @section = Section.find(params[:id])
    if params[:popup]
      @popup_mode = true
      render :layout => 'admin_popup'
    end
  end

  def update
    @section = @bulletin.sections.find(params[:id])
    if @section.update_attributes(params[:section])
      if params[:popup]
        render :layout => 'admin_close_popup', :text => ''
      else
        flash[:notice] = _('Section was successfully updated.')
        redirect_to :action => 'edit'
      end
    else
      render :action => 'edit'
    end
  end

  def destroy
    section = @bulletin.sections.find(params[:id]).destroy
    redirect_to :action => 'index'
  end

  protected
  
  def load_bulletin  
    @bulletin = @project.bulletins.find(params[:bulletin_id])
  end
end
