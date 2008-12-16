class AddBulletinCounts < ActiveRecord::Migration
  def self.up
    add_column :bulletins, :sent_count, :integer, :default => 0
    add_column :bulletins, :fail_count, :integer, :default => 0
    begin
      Bulletin.all.each do |b|
        b.update_attributes( 
            :sent_count => b.recipient_receipts.total_received,
            :fail_count => b.recipient_receipts.total_failed
        )
      end
    rescue
      # just ignore errors!
    end
  end

  def self.down
    remove_column :bulletins, :sent_count
    remove_column :bulletins, :fail_count
  end
end
