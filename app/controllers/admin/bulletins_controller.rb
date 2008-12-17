class Admin::BulletinsController < ApplicationController
  
  layout 'admin'


  before_filter(:except => [ :index, :show, :preview ]) do | c |
    c.check_role(:edit_bulletin, :back)
  end
  before_filter(:only => [ :copy, :new, :create, :destroy ]) do |c|
    c.check_role(:create_bulletin, :back)
  end
  before_filter(:only => [ :send_bulletin ]) do |c|
    c.check_role(:send_bulletin, :back)
  end

  skip_before_filter :configure_charsets
  before_filter :configure_charsets, :except=>['show']
  
  def index
    remember_page(:bulletins_page)
    
    @bulletins = Bulletin.paginate :per_page => 10, :page => params[:page],
        :conditions => ['project_id = ?', @project.id],
        :order => 'date DESC'
  end

  def show
    @bulletin = Bulletin.find(params[:id])
  end

  def new
    @bulletin = Bulletin.new
    @bulletin.project_id = @project.id
    @templets = @project.templets.find_for_bulletin
  end

  def create
    @bulletin = Bulletin.new(params[:bulletin])
    @bulletin.project_id = @project.id
    @bulletin.filter = params[:bulletin][:filter]
    if @bulletin.save
      flash[:notice] = _('Bulletin was successfully created.')
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  #
  # create a duplicate copy of the Bulletin, including its sections!
  # 
  def copy
    @bulletin = Bulletin.find(params[:id])
    
    if (newbull = @bulletin.duplicate)
      redirect_to :action => 'edit', :id => newbull.id
    else
      redirect_to :action => 'index'
    end
  end

  def edit
    @bulletin = Bulletin.find(params[:id])
    @templets = @project.templets.find_for_bulletin
  end

  def update
    @bulletin = Bulletin.find(params[:id])
    @bulletin.filter = params[:bulletin][:filter]
    if @bulletin.update_attributes(params[:bulletin])
      flash[:notice] = _('Bulletin was successfully updated.')
      redirect_to :action => 'edit', :id => @bulletin
    else
      @templets = Templet.find(:all, :conditions => ['project_id = ? AND type IS NULL', @project.id])
      render :action => 'edit'
    end
  end

  ##
  # Generate and activate to send the bulletin. 
  #
  def send_bulletin
    
    @bulletin = Bulletin.find(params[:id])
    
    # Render the body and store in the object
    # Currently, its not possible to specify user specific information
    @bulletin.render_and_save_layouts
    begin
      @bulletin.status = 'P'
      @bulletin.save
      flash[:notice] = _('Bulletin has been scheduled for delivery!')
    rescue
      flash[:error] = _('A fatal error has occurred while compiling the temlpate!<br />Please check the template and try again!')
    end
    
    redirect_to :action => 'index'
  end
  
  ##
  # Abort the send of the bulletin
  #
  def abort_send
    
    @bulletin = Bulletin.find(params[:id])
    
    if (@bulletin.is_status('P')) 
      @bulletin.status = 'O' # open!
      @bulletin.clear_rendered
      @bulletin.save
      flash[:notice] = _('Send aborted!')
    else
      flash[:warning] = _('Unable to abort sending, as the bulletin is now being sent!')
    end

    redirect_to :action => 'index'   
  end
  
  #
  # Send a test email
  #
  def send_test
    @bulletin = @project.bulletins.find(params[:id])    
    
    if request.post?
      addr = params[:recipient][:email]
      recip = @project.recipients.find_by_email(addr)
      if ! recip
        recip = Recipient.new(:email => addr, :firstname => 'Sample', :surname => 'User')
        subscription = Subscription.new( :project => @project, :recipient => recip )
      else
        subscription = @project.subscriptions.find_by_recipient_id( recip.id )
      end
      
      #begin 
        BulkMailer::deliver_bulletin(@bulletin, subscription)
        flash[:notice] = _("Test e-mail sent successfully!")
        redirect_to :action => 'index'
      #rescue
      #  flash[:error] = "Unable to send the test email! " + $!
      #end
    end
  end

  def destroy
    Bulletin.find(params[:id]).destroy
    redirect_to :action => 'index'
  end
  
  #
  # Live edit and special preview functions
  # 
  def preview_edit

    layout_style = nil
    if (params[:layout])
      layout_style = params[:layout]
    end


    begin
      @bulletin = Bulletin.find(params[:id])
      @bulletin_layout = @bulletin.layout_for_editing(layout_style, self)
      headers["Content-Type"] = @bulletin_layout.filetype + "; charset=" + @bulletin_layout.charset
      render :text => @bulletin_layout.rendered, :layout => 'bulletin'
      return
    rescue SyntaxError
      @error = _('A fatal error has occurred while compiling the temlpate!') + 
          '<br /><br />ERROR: '+$!
    end
    render :action => 'error', :layout => 'bulletin'
  end
  
  def preview
    layout_style = nil
    if (params[:layout])
      layout_style = params[:layout]
    end

    begin
      @bulletin = Bulletin.find(params[:id])
      bl = @bulletin.layout(layout_style)
      headers["Content-Type"] = bl.filetype + "; charset=" + bl.charset
      recip = Recipient.new(:email => 'sample@fakeuser.com', :firstname => 'Sample', :surname => "User")
      subscrip = Subscription.new( :project => @project, :recipient => recip )
    
      render :text => bl.rendered_with_filter( subscrip ), :layout => 'bulletin'
    rescue SyntaxError
      @error = _('A fatal error has occurred while compiling the temlpate!') + 
          '<br /><br />ERROR: '+$!
      render :action => 'error', :layout => 'bulletin'
    end
  end

  def live_edit
    # show the live edit page which includes an iframe to 
    # the actual bulletin to update. 

    @bulletin = Bulletin.find(params[:id])    
    @edit_mode = (params[:edit_mode])

    render :layout => false
  end
  
  def live_edit_header
    @bulletin = @project.bulletins.find(params[:id]) 
    @edit_mode = (params[:edit_mode])
    render :layout => false
  end
  
  def stats
    @bulletin = @project.bulletins.find(params[:id])
    @stats = @bulletin.statistics
  end
  
end
