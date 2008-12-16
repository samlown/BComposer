class RecipientReceipt < ActiveRecord::Base

  belongs_to :bulletin
  belongs_to :recipient

  after_create :update_bulletin_stats

  # status maybe:
  #   - F - Failed
  #   - R - Received
 
  def update_bulletin_stats
    self.bulletin.increment!( status == 'R' ? :sent_count : :fail_count )
  end

end
