class Subscription < ActiveRecord::Base
  
  belongs_to :recipient
  belongs_to :project

  # A list of valid states that the state field may become
  # including a common name.
  @@valid_states = {
      'P' => _('Pending'),
      'F' => _('Forced'),
      'C' => _('Confirmed'),
      'R' => _('Removed'),
  }

  def initialize( attribs = {} )
    super(attribs)
    self.state = 'P' if attribs.nil? or ! attribs[:state]
  end

  def valid_states
    list = Hash.new
    @@valid_states.each_pair do | k, v |
      list[v] = k
    end
    list
  end
  
  def status_text
    return @@valid_states[self.state]
  end
  
  #
  # Can the user receive messages?
  # For this to be true they must be confirmed (or similar)
  #
  def can_receive?
    if (self.state == 'C' or self.state == 'F')
      return true
    end
    return false
  end
  
  # Generate a confirmation code and store
  def generate_confirm_code
    chars = ("A".."Z").to_a + ("0".."9").to_a
    code = ""
    20.times { |i| code << chars[rand(chars.size-1)] }
    # add the ID to ensure always unique!
    code << self.recipient_id.to_s + self.project_id.to_s

    self.confirm_code = code
  end
  
  # confirm recipient
  #  - Check to ensure the code is correct
  #  - Set the recipient status to confirmed
  def confirm( code )
    if (code == self.confirm_code)
      self.confirm_code = nil
      self.state = 'C'
      self.save!
      # check and store new data for recipient
      if self.recipient.new_data
        data = YAML.load( recipient.new_data )
        if data
          recipient.update_attributes( data )
          recipient.new_data = nil
          recipient.confirmed_real = true
          recipient.save
        end
      end
    else
      raise "Confirmation code not valid for this recipient!"
    end
    return true
  end
  
  def remove( code )
    if (code == self.confirm_code)
      self.confirm_code = nil
      self.state = 'R'
      self.save
    else
      raise "Confirmation code not valid for this recipient!"
    end
    return true
  end
  
  def confirm_link
    confirm_url
  end
  
  # Provide a URL with the confirmation link, based on the 
  # domain provided by the project.
  def confirm_url
    generate_confirm_code
    save if not new_record?
    project.full_domain + '/recipients/confirm/' + self.confirm_code.to_s
  end
  
  def remove_url
    generate_confirm_code
    save if not new_record?
    project.full_domain + '/recipients/remove/' + self.confirm_code.to_s
  end
  
  def profile_url
    generate_confirm_code
    save if not new_record?
    project.full_domain + '/recipients/profile/' + self.confirm_code.to_s
  end
  
  def safe_method?( method )
    return true if ['confirm_url', 'remove_url', 'confirm_link', 'profile_url'].include? method    
  end
  
  #########################################################
  # Recipient management functions
  
  #
  # Create a new recipient in the database associated with the project.
  # 
  # Handles all the intelligence required to do with subscription set
  # and project groups.
  # 
  # Designed to be used with raw attribute data.
  # 
  # Parameters:
  #  * recipient = object who is being subscribed
  #  * project = name of the project to subscribe to
  #  * :notify = if true, they will be notified of the subscription.
  #              This is true by default!
  #             
  def self.subscribe( recipient, project, opts = {} )
    opts.update( :notify => true ) if (opts[:notify].nil?)
    
    # Check that the recipient is valid!
    if ! recipient.valid?
      return
    end
    
    # perform quick search for previous entry in this project group
    # Also provides original data!
    recip = project.project_group.recipients.find_by_email( recipient.email )
    
    if (recip)
      # check if already member of project
      rp = recip.subscriptions.find_by_project_id( project.id )
      if rp and rp.state != 'R'
        recipient.errors.add :email, _("Already registered to project!")
        return
      end
    else 
      # Create recipient
      recip = Recipient.new(:email => recipient.email, :project_group_id => project.project_group_id)
    end
    
    # Store temporary attributes based on copy with key fields removed
    d = recipient.attributes.dup
    d.delete('updated_on')
    d.delete('created_on')
    d.delete('project_group_id')
    d.delete('email')
    d.delete('new_data')
    recip.new_data = d.to_yaml
    recip.save
    if not rp
      rp = recip.subscriptions.build( :project_id => project.id )
    end
    rp.state = 'P'
    rp.save!
    
    if (opts[:notify] == true)
      Notifier::deliver_status_notify( :subscription => rp, :recipient => recipient ) # send notification with full details
    end
    # return with the new subscription object
    return rp
  end
  
  
  #
  # Confirm the subscription code provided
  # 
  def self.subscribe_confirm( project, code, opts = {} )
    opts.update( :notify => true ) if (opts[:notify].nil?)
    
    # check the DB for the code
    rp = project.subscriptions.find_by_confirm_code( code )
    raise _("Recipient could not be matched with code.") if (! rp)
    
    if rp.confirm(code)
      Notifier::deliver_status_notify( :subscription => rp )
    end
    return rp.recipient
  end
  
  # Prepare the user for removal
  def self.unsubscribe( recipient, project, opts = {} )
    opts.update( :notify => true ) if (opts[:notify].nil?)
    
    rp = recipient.subscriptions.find_by_project_id( project.id )
    
    if rp.state == 'R'
      # already removed!
      raise _("Recipient is not in the database!")
    end
    
    # not much more we can do, send them an email
    Notifier::deliver_status_notify( :subscription => rp, :email => 'EMAIL_UNSUBSCRIBE' )
  end
  
  def self.unsubscribe_confirm( project, code, opts = {} )
    opts.update( :notify => true ) if (opts[:notify].nil?)
    
    rp = project.subscriptions.find_by_confirm_code( code )
    raise _("Unable to find recipient from confirmation code!") if (! rp)
    
    if rp.remove( code ) and opts[:notify]
      Notifier::deliver_status_notify( :subscription => rp )
    end
    return rp.recipient
  end

  def self.valid_filter
    ["(subscriptions.state = 'C' OR subscriptions.state = 'F')"]
  end

end
