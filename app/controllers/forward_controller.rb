class ForwardController < ApplicationController

  layout 'project'

  skip_before_filter :login_required
  
  before_filter :prepare_project_header_and_footer
  
  # Provide a form to allow the page to be fowarded
  # If posted data, the data will be used to send an email
  # which contains a link to the page.
  def page
    if request.post?
      # create full URL from provided details
      @bulletin = @project.bulletins.find_by_name(params[:bulletin_name])
      if (@bulletin)
        forward_url = BcomposerLinkHelper.url_for(:page, :bulletin => @bulletin, :page => params[:page_name])
        email = @project.templets.find_by_name('EMAIL_FORWARD_PAGE')
        Notifier::deliver_message(email, :recipient => @recipient, :forward_url => forward_url, :comment => params[:comment])
        
        render :text => @project.templets.find_by_name('PAGE_FORWARD_PAGE_OK').render( @project, params ), :layout => true
        return
      end
    end
    render :text => @project.templets.find_by_name('PAGE_FORWARD_PAGE').render( @project, params ), :layout => true
  end
  
  # Provide a form to allow the bulletin to be forwarded 
  # to someone.
  # When posted data present, the email is sent and the user
  # is sent back to where they came from.
  def bulletin
    if request.post?
      # create full URL from provided details
      @bulletin = @project.bulletins.find_by_title(params[:bulletin_title])
      if (@bulletin)
        subscriber = @project.subscriptions.build()
        subscriber.recipient = Recipient.new( :email => params[:recipient][:email] )
        BulkMailer.deliver_bulletin(@bulletin, subscriber, "Fwd: " + @bulletin.subject)

      end

    end
    render :text => @project.templets.find_by_name('PAGE_FORWARD_BULLETIN').render( @project, params ), :layout => true

  end
  
end
