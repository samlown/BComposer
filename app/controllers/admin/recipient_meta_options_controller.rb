class Admin::RecipientMetaOptionsController < ApplicationController

  skip_before_filter :require_project
  before_filter :load_project 
  before_filter :require_admin_or_project
  before_filter() do | c |
    c.check_role(:edit_recipients, :back)
  end

  before_filter :load_project_group
  
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @recipient_meta_options = @project_group.paginate :per_page => 15,
      :page => params[:page]
  end

  def show
    @recipient_meta_option = RecipientMetaOption.find(params[:id])
  end

  def new
    
    @recipient_meta_option = RecipientMetaOption.new
  end

  def create
    @recipient_meta_option = RecipientMetaOption.new(params[:recipient_meta_option])
    if @recipient_meta_option.save
      flash[:notice] = 'RecipientMetaOption was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @recipient_meta_option = RecipientMetaOption.find(params[:id])
  end

  def update
    @recipient_meta_option = RecipientMetaOption.find(params[:id])
    if @recipient_meta_option.update_attributes(params[:recipient_meta_option])
      flash[:notice] = 'RecipientMetaOption was successfully updated.'
      redirect_to :action => 'show', :id => @recipient_meta_option
    else
      render :action => 'edit'
    end
  end

  def destroy
    RecipientMetaOption.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  protected
  
  def load_project_group
    @project_group = ProjectGroup.find( params[:project_group_id] )    
  end
end
