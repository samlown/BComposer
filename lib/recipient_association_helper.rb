
#
# Provide extra support functions for the link between recipients and projects.
# 
# These functions should be bi-directional, unless stated otherwise.
# 
module RecipientAssociationHelper
  
  def valid
    find(:all, :conditions => ['subscriptions.status = "C" OR subscriptions.status = "F"'])
  end
  
  def valid_count
    count(:all, :conditions => ['subscriptions.status = "C" OR subscriptions.status = "F"'])
  end

end