class Admin::TempletLayoutsController < ApplicationController
  layout 'admin'

  skip_before_filter :require_project
  before_filter :load_project
  before_filter :load_templet
  before_filter(:except => [ :index ]) do | c |
    c.check_role(:edit_templates, :back)
  end
  before_filter :require_admin_or_project

  def index
    @templet_layouts = @templet.templet_layouts.paginate :per_page => 10, :page => params[:page]
  end

  def show
    @templet_layout = TempletLayout.find(params[:id])
  end

  def new
    @templet_layout = TempletLayout.new
    @templet_layout.templet_id = @templet.id
    # defaults
    if (params[:edit_as_html] != nil) 
      @templet_layout.edit_as_raw = (! params[:edit_as_html])
    end
    # defaults
    @templet_layout.filetype = "text/html"
    @templet_layout.charset = "UTF-8"
  end

  def create
    @templet_layout = @templet.templet_layouts.build(params[:templet_layout])
    if @templet_layout.save
      flash[:notice] = 'TempletLayout was successfully created.'
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def edit
    @templet_layout = @templet.templet_layouts.find(params[:id])
    # defaults
    if (params[:edit_as_html] != nil) 
      @templet_layout.edit_as_raw = (params[:edit_as_html] == 'false')
    end
  end

  def update
    @templet_layout = TempletLayout.find(params[:id])
    if @templet_layout.update_attributes(params[:templet_layout])
      # fix for strange charset bug?!
      @templet_layout.charset = params[:templet_layout][:charset]
      # set layout if its been set by the admin
      if current_user.is_admin?
        @templet_layout.filter = params[:templet_layout][:filter] if params[:templet_layout][:filter]
      end
      @templet_layout.save
      flash[:notice] = _('TempletLayout was successfully updated.')
      # redirect_to :action => 'show', :id => @templet_layout
      redirect_to :action => 'edit', :id => @templet_layout
    else
      render :action => 'edit'
    end
  end

  def destroy
    @templet_layout = TempletLayout.find(params[:id])
    t_id = @templet_layout.templet_id
    @templet_layout.destroy
    redirect_to :action => 'index'
  end
 
  def choose_form
    @templet_layout = TempletLayout.new( params[:templet_layout] )
    if params[:edit_as_html] == 'true'
      @templet_layout.edit_as_raw = false
      render :update do | page |
        page.replace_html 'edit_body_form', :partial => 'gui_form'
      end
    else
      @templet_layout.edit_as_raw = true
      # for some lame reason, we need the id to correctly create the 
      # id for the editor field
      id = (params[:id].blank? ? '' : params[:id])
      render :update do | page |
        # grab the FCKEditor content first
        page << "var data = FCKeditorAPI.GetInstance('templet_layout_#{id}_data_editor').GetXHTML()"
        page.replace_html 'edit_body_form', :partial => 'text_form'
        page << "document.getElementById('templet_layout_data').defaultValue = data"
      end
    end
  end

  protected

  def load_templet
    @templet = Templet.find(params[:templet_id])
  end 
  
end
