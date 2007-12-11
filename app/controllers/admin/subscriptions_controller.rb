class Admin::SubscriptionsController < ApplicationController
  layout 'admin'

  skip_before_filter :require_project
  before_filter :load_project 
  before_filter :require_admin_or_project
  before_filter() do | c |
    c.check_role(:edit_recipients, :back)
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ], 
      :redirect_to => { :action => :list }

  def index
    login
    render :action => 'list'
  end
 
  def list
    @search = params[:search] if (params[:search])
    @filter = params[:filter]
    if (params[:bulletin_id])
      @bulletin = Bulletin.find(params[:bulletin_id])
            
    else
      cond_str = ""
      cond_vars = { }
      if @project
        cond_str += "subscriptions.project_id = :pid "
        cond_vars.update( :pid => @project.id )
      end
      if (@search)
        s = '%' + @search + '%'
        cond_str += 'AND (email LIKE :s OR firstname LIKE :s OR surname LIKE :s) '
        cond_vars[:s] = s
      end
      if (@filter)
        cond_str += 'AND (subscriptions.state = :t) '
        cond_vars[:t] = @filter
      end
      
      @subscription_pages, @subscriptions = paginate :subscriptions, :per_page => 10,
          :conditions => [ cond_str, cond_vars ],
          :include => :recipient
     
    end
  end

  def update
    @subscription = @project.subscriptions.find_by_recipient_id( params[:id] )
    @recipient = @subscription.recipient
    
    # check for a change in status
    notify = (@subscription.state != params[:subscription][:state])? true : false

    @subscription.state = params[:subscription][:state]
    @subscription.save
    if @recipient.update_attributes(params[:recipient])
      flash[:notice] = _('Updated')
      if (notify and params[:notify])
        Notifier::deliver_status_notify(:subscription => @subscription)
        flash[:notice] << ' - '+_('recipient notified')
      end
      
      redirect_to :action => 'edit', :id => @subscription.id
    else
      render :action => 'edit'
    end
  end
 
  
  def new
    @recipient = Recipient.new(params[:recipient])
  end 


  def create
    # check to see if they exist
    @recipient = @project.project_group.recipients.find_by_email(params[:recipient][:email])
    
    if @recipient
      # alread a member of the group, check if already subscribed
      @subscription = @project.subscriptions.find_by_recipient_id( @recipient.id )
      if (@subscription)
        @recipient.errors.add(:email, _("address already subscribed to this project!"))
        render :action => 'new'
        return
      end
    else
      # create a new recipient
      @recipient = Recipient.new( params[:recipient] )
      @recipient.project_group = @project.project_group
      if ! @recipient.save
        render :action => 'new'
        return
      end
    end
    
    @subscription = @project.subscriptions.create( :recipient_id => @recipient.id )
    @subscription.state = 'F'
    if @subscription
      flash[:notice] = _("New subscription added successfully!")
      redirect_to :action => 'edit', :id => @subscription.id
    else
      flash.now[:warning] = _("An error ocurred while saving the recipient's subscription!")
      render :action => 'new'
    end
  end

  def destroy
    @project.subscriptions.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def edit
    @subscription = @project.subscriptions.find_by_id(params[:id])
    if ! @subscription
      flash.now[:error] = "Unable to find subscription!"
    else
      @recipient = @subscription.recipient
    end
  end
  
end