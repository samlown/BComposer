class Admin::SectionsController < ApplicationController
  layout 'admin'

  before_filter(:except => [ :list, :show ]) do | c |
    c.check_role(:edit_section, :back)
  end

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @bulletin = Bulletin.find(params[:bulletin_id])
    @section_pages, @sections = paginate :sections, :per_page => 10,
        :conditions => ['bulletin_id = ?', @bulletin.id]
  end

  def show
    @section = Section.find(params[:id])
  end

  def new 
    @bulletin = Bulletin.find(params[:bulletin_id])
    @section = Section.new
    @section.bulletin_id = @bulletin.id
  end

  def create
    @section = Section.new(params[:section])
    @section.date_created = Time.now
    if @section.save
      flash[:notice] = _('Section was successfully created.')
      redirect_to :action => 'list', :bulletin_id => @section.bulletin
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
    @section = Section.find(params[:id])
    if @section.update_attributes(params[:section])
      if params[:popup]
        render :layout => 'admin_close_popup', :text => ''
      else
        flash[:notice] = _('Section was successfully updated.')
        redirect_to :action => 'show', :id => @section
      end
    else
      render :action => 'edit'
    end
  end

  def destroy
    section = Section.find(params[:id])
    id = section.bulletin_id
    section.destroy
    redirect_to :action => 'list', :bulletin_id => id
  end
end
