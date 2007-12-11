class MoveSubscriptions < ActiveRecord::Migration
  def self.up
    # go through each project and their recipients, create each one a new subscription entry
    # if they don't already have one
    
    Project.find(:all).each do | project |
      puts "Updating project: " + project.name
      count = 0
      skipped = 0
      rps = {}
      # pre-find all subscription objects
      Subscription.find(:all, :conditions => ['project_id = ?', project.id]).each do | rp |
        rps[ rp.recipient_id ] = true
      end
      puts "Generated list of subscriptions, count: " + rps.size.to_s
      
      Recipient.find(:all, :conditions => ['project_id = ?', project.id]).each do | recipient |
        if (! rps[recipient.id])
          recipient.subscriptions.create( :project_id => project.id, :state => recipient.state )
          count += 1
        else
          rps.delete(recipient.id)
          skipped += 1
        end
      end
      
      puts "Total updated: " + count.to_s
      puts "Total skipped: " + skipped.to_s
    end
  end

  def self.down
  end
end
