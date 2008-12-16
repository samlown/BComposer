class Admin::RecipientsController < ApplicationController
  layout 'admin'

  skip_before_filter :require_project
  before_filter :require_admin

  def index
    @search = params[:search] if (params[:search])

    cond_str = ""
    cond_vars = { }
    if (@search)
      s = '%' + @search + '%'
      cond_str += '(email LIKE :s OR firstname LIKE :s OR surname LIKE :s)'
      cond_vars[:s] = s
    end
     
    @recipients = Recipient.paginate :per_page => 10, :page => params[:page],
        :conditions => (cond_str.blank?) ? nil : [ cond_str, cond_vars ],
        :include => :subscriptions
  end

  def show
    if (session[:user])
      @recipient = Recipient.find(params[:id])
    else
      @recipient = session[:recipient]
    end
    # @project = @recipient.project
  end


  def create
    @recipient = Recipient.new(params[:recipient])

    if @recipient.save
      flash[:notice] = _('New recipient has been stored')
      redirect_to :action => 'show', :id => @recipient
    else
      render :action => 'new'
    end
  end

  def update
    @recipient = Recipient.find(params[:id])
    if @recipient.update_attributes(params[:recipient])
      flash[:notice] = _('Updated')
      redirect_to :action => 'show', :id => @recipient
    else
      render :action => 'edit'
    end
  end
 
  
  def new
    @recipient = Recipient.new
  end 

  def destroy
    Recipient.find(params[:id]).destroy
    redirect_to :action => 'index'
  end
  
  def edit
    @recipient = Recipient.find(params[:id])
  end
  
end
