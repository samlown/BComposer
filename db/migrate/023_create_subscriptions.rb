class CreateSubscriptions < ActiveRecord::Migration
  def self.up
    create_table "subscriptions" do |t|
      t.column "recipient_id",   :integer,               :default => 0, :null => false
      t.column "project_id",     :integer,               :default => 0, :null => false
      t.column "state",          :string,   :limit => 1
      t.column "confirm_code",   :string,   :null => true
      t.column "created_on",     :datetime
      t.column "updated_on",     :timestamp
    end
  
    add_index "subscriptions", ["recipient_id", "project_id"], :name => "subscription_id"
  end

  def self.down
    drop_table :subscriptions
  end
end
