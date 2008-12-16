class RecipientsController < ApplicationController

  layout 'project'

  skip_before_filter :login_required

  before_filter :prepare_project_header_and_footer

  def index
    subscribe
  end

  #
  # Allow the user to subscribe to the current project.
  # They will be sent an email confirmation.
  # 
  def subscribe
    @recipient = Recipient.new(params[:recipient])

    if request.post?
      s = Subscription.subscribe( @recipient, @project )
      if s
        render :text => @project.templets.find_by_name('PAGE_SUBSCRIBE_OK').render( @project ), :layout => true
        return
      end
      flash.now[:error] = _("Unable to accept your request!")
    end
    
    render :text => @project.templets.find_by_name('PAGE_SUBSCRIBE').render( @project, :recipient => @recipient ), :layout => true
  end

  #
  # Allow for the confirmation of the recipient.
  # Valid for:
  #   
  #
  def confirm
    # try to grab the confirmation code
    code = params[:id]
    if (! code)
      flash[:error] = "No confirmation code provided!"
      redirect_to :action => 'subscribe'
      return
    end
    begin
      @recipient = Subscription.subscribe_confirm( @project, code )
    rescue
      flash[:error] = $!
      redirect_to :action => 'subscribe'
      return
    end
    render :text => @project.templets.find_by_name('PAGE_CONFIRMED').render( @project ), :layout => true
  end
  
  #
  # Unsubscribe the user from the project.
  #
  def unsubscribe
    if request.post?
      @recipient = Recipient.find_by_email( params[:recipient][:email] )
      if (! @recipient)
        flash.now[:error] = _("Email address not found in the database!")
      elsif Subscription.unsubscribe( @recipient, @project )
        render :text => @project.templets.find_by_name('PAGE_UNSUBSCRIBE_OK').render( @project ), :layout => true
        return
      end
    end
    render :text => @project.templets.find_by_name('PAGE_UNSUBSCRIBE').render( @project ), :layout => true
  end
  
  def remove
    code = params[:id]
    if (! code)
      flash[:error] = "No confirmation code provided!"
      redirect_to :action => 'unsubscribe'
    else
      begin
        @recipient = Subscription.unsubscribe_confirm( @project, code )
      rescue
        flash[:error] = $!
        redirect_to :action => 'unsubscribe'
        return
      end
    end
    render :text => @project.templets.find_by_name('PAGE_REMOVED').render( @project ), :layout => true
  end

  # Allow the recipient to edit their profile. Consists of several steps:
  # 1. Submit email address that includes auth-code
  # 2. They return with code that allows to view their data, sets session data
  #    to ensure they stay connected. Presented with Edit form.
  # 3. New data submitted.
  def profile
    if params[:id]
      # match the code and grant the session
      @subscription = @project.subscriptions.find_by_confirm_code( params[:id] )
      if ! @subscription
        flash.now[:error] = _("Unable to match confirmation code!")
      else
        @subscription.confirm( params[:id] )
        session[:subscription_id] = @subscription.id
        redirect_to :action => 'profile', :id => nil
        return
      end
    end
    
    if session[:subscription_id]
      @subscription = Subscription.find( session[:subscription_id] ) if (! @subscription)
      if request.post?
        if @subscription.recipient.update_attributes( params[:recipient] )
          session[:subscription_id] = nil
          render_page 'PAGE_PROFILE_OK'
          return
        else
          @recipient = @subscription.recipient
          flash.now[:error] = _("Unable to save profile!")
        end
      end
      
      render_page 'PAGE_PROFILE_FORM', :subscription => @subscription, :recipient => @subscription.recipient
    else
      if request.post?
        recipient = @project.recipients.find_by_email( params[:recipient][:email] )
        if (! recipient)
          flash.now[:error] = _('Unable to find email address in database!')
        else
          sub = @project.subscriptions.find_by_recipient_id( recipient.id )
          Notifier.deliver_message( 'EMAIL_PROFILE_CONFIRM', :subscription => sub )
          flash.now[:notice] = _('Request accepted, please check your mail!')
        end
      else
        recipient = Recipient.new(params[:recipient])
      end
      # show enter email form
      render_page 'PAGE_PROFILE_EMAIL', :recipient => recipient 
    end
  end

  #
  # Send a copy of the bulletin to a friend
  # 
  def sendtofriend
    @bulletin = Bulletin.find(params[:bulletin_id])
    
    if (@bulletin.nil?)
      flash[:warning] = "Boletín Invalido!"
      @bulletin = Bulletin.new
    elsif (@bulletin.status == 'SSS') # != 'S'
      flash[:warning] = "Boletín invalido!"
      @bulletin = Bulletin.new
    elsif request.post?
      # send a copy of the boletin to the user specified
      @recipient = Recipient.new
      @recipient.email = params[:recipient][:email]
      @recipient.state = 'F' # set forced confirmation!
      pass = Recipient.generate_password
      @recipient.password = pass
      @recipient.password_confirmation = pass
      @recipient.project_id = @bulletin.project_id
      if (@recipient.save)
        BulkMailer.deliver_bulletin(@bulletin.layout, "Fwd: " + @bulletin.project.name + ' - ' + @bulletin.title, @recipient)
        flash[:notice] = "Gracias. Su solicitud ha sido procesada con &eacute;xito."
      end
    end
  end
  
  def sendtofriend
    forward_bulletin
    render :action => 'forward_bulletin'
  end
  
  protected

end
