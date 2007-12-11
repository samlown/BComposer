class RecipientReceipt < ActiveRecord::Base
  belongs_to :bulletin
  belongs_to :recipient
  
  # status maybe:
  #   - F - Failed
  #   - R - Received
end
