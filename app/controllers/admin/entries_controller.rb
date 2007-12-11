class Admin::EntriesController < ApplicationController
  layout 'admin'

  before_filter(:except => [ :list, :show ]) do | c |
    c.check_role(:edit_entry, :back)
  end

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @section = Section.find(params[:section_id])
    @entry_pages, @entries = paginate :entries, :per_page => 20,
        :conditions => ['section_id = ?', @section.id], :order => 'position'
  end
  
  def move_up
    @entry = Entry.find(params[:id])
    @entry.section.move_up_entry(@entry)
   
    redirect_to :action => 'list', :section_id => @entry.section_id
  end
  
  def move_down
    @entry = Entry.find(params[:id])
    @entry.section.move_down_entry(@entry)
   
    redirect_to :action => 'list', :section_id => @entry.section_id
  end

  def show
    @entry = Entry.find(params[:id])
  end

  def new
    @section = Section.find(params[:section_id])
    @entry = Entry.new
    @entry.position = params[:position] if params[:position]
    @entry.section_id = @section.id
    if params[:popup]
      @popup_mode = true
      render :layout => 'admin_popup'
    end
  end

  def create
    @entry = Entry.new(params[:entry])
    
    @entry.position = @entry.section.entries.count + 1 if ! @entry.position
    
    @entry.date_created = Time.now
    @entry.date_updated = Time.now
    if @entry.save
      @entry.section.reorder_entries
      if params[:popup]
        render :layout => 'admin_close_popup', :text => ''
      else
        flash[:notice] = _('Entry was successfully created.')
        redirect_to :action => 'list', :section_id => @entry.section_id
      end
    else
      render :action => 'new'
    end
  end

  def edit
    @entry = Entry.find(params[:id])
    if params[:popup]
      @popup_mode = true
      render :layout => 'admin_popup'
    end
  end

  def update
    @entry = Entry.find(params[:id])
    @entry.date_updated = Time.now
    if @entry.update_attributes(params[:entry])
      if params[:popup]
        render :layout => 'admin_close_popup', :text => ''
      else
        flash[:notice] = _('Entry was successfully updated.')
        redirect_to :action => 'show', :id => @entry
      end
    else
      render :action => 'edit'
    end
  end

  def destroy
    entry = Entry.find(params[:id])
    section_id = entry.section_id
    entry.destroy
    redirect_to :action => 'list', :section_id => section_id
  end
end
