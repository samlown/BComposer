
require "base64"

class StatsController < ApplicationController
  
  # no need for sessions here!
  session :off 
  
  skip_before_filter :login_required
  skip_before_filter :configure_charsets
  skip_before_filter :require_project

  # Add an entry to the statistics counter and
  # provide the calling function with a tiny image
  def add
    
    ary = Marshal::load( Base64::decode64( params[:id].gsub(/\.png$/, '') ) )
    
    logger.info puts "Stats Entry: " + ary[0].to_s + " " + ary[1].to_s
    
    begin
      recipient = Recipient.find(ary[0].to_i)
      if ! recipient.confirmed_real
        recipient.confirmed_real = true
        recipient.save
      end
      receipt = recipient.recipient_receipts.find(:first, :conditions => ['bulletin_id = ?', ary[1]])
      receipt.read = Time.now
      receipt.hits = receipt.hits + 1
      receipt.save
    rescue
      # nothing
      logger.info "ERROR: Stats update failed: "+$!
    end
    
    render :file => 'public/images/spek.png', :type => :png,
       :use_full_path => false, :content_type => 'image/png', :layout => nil
  end
end
