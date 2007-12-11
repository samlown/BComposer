#
# Methods to help the production of statistics.
# 
# This module is designed to be included in the bulletin / recipient_receipt
# relationship.
#
module BulletinRecipientStatistics

  def first_sent
    find(:first, :order => 'received ASC', :conditions => ['received IS NOT NULL'])
  end
  
  def last_sent
    find(:first, :order => 'received DESC', :conditions => ['received IS NOT NULL'])
  end
  
  def first_read
    find(:first, :order => '`read` ASC', :conditions => ['`read` IS NOT NULL'])
  end
  
  def last_read
    find(:first, :order => '`read` DESC', :conditions => ['`read` IS NOT NULL'])
  end
  
  def total_sent
    count()
  end
  
  def total_received
    count(:conditions => ["status = 'R'"])    
  end
  
  def total_failed
    count(:conditions => ["status = 'F'"])
  end
  
  def total_read
    count(:conditions => ["`read` IS NOT NULL"])    
  end
  
  def total_hits
    sum('hits')
  end
end
