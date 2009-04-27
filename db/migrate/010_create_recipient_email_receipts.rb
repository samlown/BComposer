class CreateRecipientEmailReceipts < ActiveRecord::Migration
  def self.up
    create_table "recipient_email_receipts", :id => false do |t|
      t.column "bulletin_id",  :integer,               :default => 0, :null => false
      t.column "recipient_id", :integer,               :default => 0, :null => false
      t.column "status",       :string,   :limit => 1
      t.column "received",     :datetime
    end
  
    add_index "recipient_email_receipts", ["bulletin_id", "recipient_id"], :name => "bulletin_recipient_id"
    
  end

  def self.down
  end
end
