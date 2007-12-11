class Admin::RecipientsController < ApplicationController
  layout 'admin'

  skip_before_filter :require_project
  before_filter :require_admin

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ], 
      :redirect_to => { :action => :list }

  def index
    login
    render :action => 'list'
  end
 
  def list
    @search = params[:search] if (params[:search])

    cond_str = ""
    cond_vars = { }
    if (@search)
      s = '%' + @search + '%'
      cond_str += '(email LIKE :s OR firstname LIKE :s OR surname LIKE :s)'
      cond_vars[:s] = s
    end
     
    @recipient_pages, @recipients = paginate :recipients, :per_page => 10,
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
    redirect_to :action => 'list'
  end
  
  def edit
    @recipient = Recipient.find(params[:id])
  end
  
end