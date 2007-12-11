class BulkMailer < ActionMailer::Base

  def bulletin(bulletin, subscription, subject = nil)
    recipients subscription.recipient.email
    from bulletin.project.sender
    subject ( subject.nil? ? bulletin.subject : subject )
    
    @content_type = "multipart/alternative"
    bulletin.templet.templet_layouts.find(:all, :order => 'name').each do | layout |
      # skip special layouts
      next if layout.name =~ /^print/
      content_type = layout.filetype + "; charset=" + layout.charset
      part :content_type => content_type,
           :body => bulletin.layout(layout.name, subscription.recipient).rendered_with_filter( subscription )
    end

  end

  def delivery_report( bulletin, time_start, time_end, total_sent, total_failed, failures )
    recipients bulletin.project.report_recipients
    from bulletin.project.sender
    subject "Delivery Report: " + bulletin.subject
    
    @body[:bulletin_name] = bulletin.full_title
    @body[:total_failed] = total_failed
    @body[:total_sent] = total_sent
    @body[:failures] = failures
    @body[:time_start] = time_start
    @body[:time_end] = time_end
  end
  
  # Currently supported options:
  #   :time_start
  #   :recipient_count
  def delivery_start( bulletin, opts )
    recipients bulletin.project.report_recipients
    from bulletin.project.sender
    subject "Delivery Start: " + bulletin.subject
    
    @body[:bulletin_name] = bulletin.full_title
    @body.update( opts )
  end

end