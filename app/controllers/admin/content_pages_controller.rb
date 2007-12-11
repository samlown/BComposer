class Admin::ContentPagesController < ApplicationController
  
  layout 'admin'
 
  before_filter :require_bulletin, :only => ['list', 'new'] 
 
  before_filter :except => [ :list, :show ] do | c |
    c.check_role(:edit_pages, :back)
  end
 
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @mode = params[:mode] ? params[:mode].to_sym : nil
    @update_field = params[:field] if params[:field]
    
    @content_page_pages, @content_pages = paginate :content_pages, :per_page => 10,
      :order => 'updated_on DESC', :conditions => ['bulletin_id = ?', @bulletin.id]
      
    render :action => 'list', :layout => 'admin_popup' if @mode == :popup
  end

  def show
    @content_page = ContentPage.find(params[:id])
  end

  def new
    @content_page = ContentPage.new
    @content_page.bulletin = @bulletin
    @templets = @project.templets.find(:all, :conditions => ['type = ?', 'ContentTemplet'])
  end

  def create
    @content_page = ContentPage.new(params[:content_page])
    @bulletin = @content_page.bulletin
    if @content_page.save
      flash[:notice] = _('ContentPage was successfully created.')
      redirect_to :action => 'list', :bulletin_id => @content_page.bulletin_id
    else
      render :action => 'new'
    end
  end

  def edit
    @content_page = ContentPage.find(params[:id])
    @templets = @project.templets.find(:all, :conditions => ['type = ?', 'ContentTemplet'])
  end

  def update
    @content_page = ContentPage.find(params[:id])
    if @content_page.update_attributes(params[:content_page])
      flash[:notice] = _('ContentPage was successfully updated.')
      redirect_to :action => 'list', :bulletin_id => @content_page.bulletin_id
    else
      @templets = @project.templets.find(:all, :conditions => ['type = ?', 'ContentTemplet'])
      render :action => 'edit'
    end
  end

  def destroy
    cp = ContentPage.find(params[:id])
    b_id = cp.bulletin_id
    cp.destroy
    redirect_to :action => 'list', :bulletin_id => b_id
  end
  
  protected
  
  def require_bulletin
    @bulletin = Bulletin.find(params[:bulletin_id])
  end
end
