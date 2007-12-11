class Admin::BulletinsController < ApplicationController
  layout 'admin'

  

  def index
    list
    render :action => 'list'
  end

  before_filter(:except => [ :list, :show, :preview ]) do | c |
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
  


  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    remember_page(:bulletins_page)
    
    @bulletin_pages, @bulletins = paginate :bulletins, :per_page => 10, 
        :conditions => ['project_id = ?', @project.id],
        :order => 'updated_on DESC'
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
      redirect_to :action => 'list'
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
      redirect_to :action => 'list'
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
      @templets = Templet.find_all(['project_id = ? AND type IS NULL', @project.id])
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
    
    redirect_to :action => 'list'
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

    redirect_to :action => 'list'   
  end
  
  #
  # Send a test email
  #
  def send_test
    @bulletin = Bulletin.find(params[:id])    
    
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
        redirect_to :action => 'list'
      #rescue
      #  flash[:error] = "Unable to send the test email! " + $!
      #end
    end
  end

  def destroy
    Bulletin.find(params[:id]).destroy
    redirect_to :action => 'list'
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
    @bulletin = Bulletin.find(params[:id]) 
    @edit_mode = (params[:edit_mode])
    render :layout => false
  end
  
  def stats
    @bulletin = Bulletin.find(params[:id])
    @stats = {}
    @stats[:date_first_sent] = (t = @bulletin.recipient_receipts.first_sent) ? t.received.to_formatted_s(:full) : ''
    @stats[:date_last_sent] = (t = @bulletin.recipient_receipts.last_sent) ? t.received.to_formatted_s(:full): ''
    @stats[:date_first_read] = (t = @bulletin.recipient_receipts.first_read) ? t.received.to_formatted_s(:full) : ''
    @stats[:date_last_read] = (t = @bulletin.recipient_receipts.last_read) ? t.read.to_formatted_s(:full) : ''
  end
  
  def entry_move_up
    entry = Entry.find(params[:id])
    entry.section.move_up_entry(entry)
   
    redirect_to :action => 'preview_edit', :id => entry.section.bulletin_id, :edit_mode => 1
  end
  
  def entry_move_down
    entry = Entry.find(params[:id])
    entry.section.move_down_entry(entry)
   
    redirect_to :action => 'preview_edit', :id => entry.section.bulletin_id, :edit_mode => 1
  end
  
  def entry_delete
    entry = Entry.find(params[:id])
    id = entry.section.bulletin_id
    
    entry.destroy
    
    redirect_to :action => 'preview_edit', :id => id, :edit_mode => 1
  end
end
