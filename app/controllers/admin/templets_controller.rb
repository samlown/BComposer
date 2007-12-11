class Admin::TempletsController < ApplicationController
  layout 'admin'

  skip_before_filter :require_project
  before_filter :load_project
  before_filter :require_admin_or_project

  before_filter(:except => [ :list, :show ]) do | c |
    c.check_role(:edit_templates, :back)
  end

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    # Prepare the current filter
    @filter = { }
    @filter[:type] = params[:filter][:type] if ! params[:filter].nil?
    if @filter[:type].blank?
      # try to grab it from the session
      @filter[:type] = session[:templets_type]
    end
    @filter[:type] = 'Templet' if @filter[:type].nil?
    # store in the session
    session[:templets_type] = @filter[:type] if session[:templets_type] != @filter[:type]
    
    # prepare the query based on the filter options
    conds_str = ""
    conds_vars = []
    if @filter[:type] != 'All'
      if @filter[:type] == 'Templet'
        conds_str += "(`type` = ? OR type IS NULL)"
      else
        conds_str += "(`type` = ?)"
      end
      conds_vars << @filter[:type]
    end
    if @project
      conds_str += " AND " if ! conds_str.blank?
      conds_str += "(project_id = (SELECT MAX(t2.project_id) FROM templets t2 WHERE (t2.project_id = ? OR t2.project_id = 0) AND templets.name = t2.name))"
      conds_vars << @project.id
    else
      conds_str += " AND " if ! conds_str.blank?
      conds_str += "project_id = 0"
    end
    
    # send the query
    @templet_pages, @templets = paginate :templets, :per_page => 20, 
       :conditions => [ conds_str ] + conds_vars,
       :order => 'name'
  end

  def show
    @templet = Templet.find(params[:id])
  end

  def new
    @templet = Templet.new
  end

  def create
    @templet = Templet.new_of_type(params[:templet][:type_name], params[:templet])
    @templet.project_id = ( @project ? @project.id : 0 )
    if @templet.save
      # try to create a new templet layout
      templet_layout = TempletLayout.new()
      templet_layout.templet = @templet
      templet_layout.name = 'main'
      if (! templet_layout.save)
        flash[:error] = 'Unable to save a template layout.'
      end
      flash[:notice] = 'Templet was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @templet = Templet.find(params[:id])
    # if template is a default one and there is a project, 
    # copy it!
    if (@project and @templet.project_id == 0)
      @templet = @templet.duplicate
      @templet.project = @project
      @templet.save
      flash.now[:notice] = "New Template created successfully!"
    end
  end

  def update
    if (! params[:templet][:subject].empty?)
      @templet = Email.find(params[:id])
    else
      @templet = Templet.find(params[:id])
    end
    if @templet.update_attributes(params[:templet])
      flash[:notice] = 'Templet was successfully updated.'
      redirect_to :action => 'show', :id => @templet
    else
      render :action => 'edit'
    end
  end

  def destroy
    Templet.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def error
    render :action => 'error';
  end
  
  def help
    render :layout => 'help';
  end
  
  #
  # Send a test email
  #
  def send_test
    email = Email.find(params[:id])
    @templet = email
    
    if request.post?
      begin
        recip = Recipient.new
        recip.email = params[:recipient][:email]
 
        Notifier::deliver_status_notify(:project => @project, :recipient => recip, :email => email)
      
        flash[:notice] = "Test e-mail sent successfully!"
        redirect_to :action => 'list'
      rescue
        flash[:error] = "Unable to send the test email! " + $!
      end
    end
  end
  
  
end
