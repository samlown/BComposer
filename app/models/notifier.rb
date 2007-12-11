class Notifier < ActionMailer::Base
 
  #
  # Send an email to the user notifying them of what has changed.
  # The correct message to be sent is automatically determined.
  # 
  # Required options:
  #  * :recipient - the receiver of the message
  #  * :project - where to get the status from
  #   or
  #  * :subscription - the combined object
  # 
  # Additional options:
  #  * :email - email object to send instead of any other
  #  
  # @param  email object  used for testing cases
  # 
  def status_notify( opts )
    if (opts[:recipient] and opts[:project])
      rp = Subscription.new(:recipient => opts[:recipient], :project => opts[:project])
      recipient = rp.recipient
    elsif (opts[:subscription])
      rp = opts[:subscription]
      # allow override of recipient (for special cases)
      recipient = opts[:recipient] ? opts[:recipient] : rp.recipient
    else
      raise "No recipient nor project!"
    end
    
    email = opts[:email]
    name = nil
        
    if (email.is_a? Email)
      name = email.name
    elsif (email.is_a? String)
      name = email
      email = nil
    elsif (rp.state == 'P') # Pending
      name = 'EMAIL_PENDING'
    elsif (rp.state == 'F') # Forced
      # no message!
    elsif (rp.state == 'C') # Confirmed
      name = 'EMAIL_CONFIRMED'
    elsif (rp.state == 'R') # Removed
      name = 'EMAIL_REMOVED'
    end
    
    if name
      # try to load the email template
      email = rp.project.templets.find_by_name( name ) if ! email
            
      recipients recipient.email
      from rp.project.sender
      subject email.subject
      @content_type = "multipart/alternative"
      email.render( :recipient => recipient, :subscription => rp ) do | body, content_type |
        part :content_type => content_type,
         :body => body
      end
    end  
  end
  
  # Send the provided email object to the recipient
  # options include:
  # * recipient
  # * layout optional
  def message(email, options)
    raise "No subscription for message!" if (! options[:subscription])
    email = options[:subscription].project.templets.find_by_name( email ) if email.is_a? String
    raise "No email object!" if (! email)
    
    recipient = options[:subscription].recipient
    options.update( :recipient => recipient )
    recipients recipient.email
    from options[:subscription].project.sender
    subject email.subject
    @content_type = "multipart/alternative"
    email.render( options ) do | body, content_type |
      part :content_type => content_type,
         :body => body
    end
  end
end
