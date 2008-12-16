class Admin::SubscriptionsController < ApplicationController
  layout 'admin'

  skip_before_filter :require_project
  before_filter :load_project 
  before_filter :require_admin_or_project
  before_filter() do | c |
    c.check_role(:edit_recipients, :back)
  end

  def index
    @search = params[:search] if (params[:search])
    @filter = params[:filter]
    if (params[:bulletin_id])
      @bulletin = @project.bulletins.find(params[:bulletin_id])
    else
      cond_strs = []
      cond_vars = { }
      if (@search)
        s = '%' + @search + '%'
        cond_strs << '(email LIKE :s OR firstname LIKE :s OR surname LIKE :s)'
        cond_vars[:s] = s
      end
      if (@filter)
        cond_strs << '(subscriptions.state = :t)'
        cond_vars[:t] = @filter
      end
      
      @subscriptions = @project.subscriptions.paginate :per_page => 10, :page => params[:page],
          :conditions => (cond_strs.empty? ? nil : [ cond_strs.join(' AND '), cond_vars ]),
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
    @recipient = @project.project_group.recipients.build(params[:recipient])
    current_recipient = @project.project_group.recipients.find_by_email(params[:recipient][:email])
    
    if current_recipient
      # alread a member of the group, check if already subscribed
      @subscription = @project.subscriptions.find_by_recipient_id( current_recipient.id )
      if (@subscription)
        @recipient.errors.add(:email, _("address already subscribed to this project!"))
        render :action => 'new'
        return
      end
      @recipient = current_recipient # copy over now!
    else
      # create a new recipient
      @recipient = @project.project_group.recipients.build( params[:recipient] )
      if ! @recipient.save
        render :action => 'new'
        return
      end
    end
    
    @subscription = @project.subscriptions.create( :recipient_id => @recipient.id )
    @subscription.state = 'F'
    if @subscription
      flash[:notice] = _("New subscription added successfully!")
      redirect_to edit_admin_project_subscription_url(@project, @subscription), :method => :get
    else
      flash.now[:warning] = _("An error ocurred while saving the recipient's subscription!")
      render :action => 'new'
    end
  end

  def destroy
    @project.subscriptions.find(params[:id]).destroy
    redirect_to :action => 'index'
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
