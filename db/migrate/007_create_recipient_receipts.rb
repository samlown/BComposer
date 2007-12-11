class CreateRecipientReceipts < ActiveRecord::Migration
  def self.up
    create_table "recipient_receipts" do |t|
      t.column "bulletin_id",  :integer,               :default => 0, :null => false
      t.column "recipient_id", :integer,               :default => 0, :null => false
      t.column "status",       :string,   :limit => 1
      t.column "received",     :datetime
      t.column "read",         :datetime
      t.column "hits",         :integer,               :default => 0, :null => false
    end
  
    add_index "recipient_receipts", ["bulletin_id", "recipient_id"], :name => "bulletin_id"

  end

  def self.down
    drop_table :recipient_receipts
  end
end
