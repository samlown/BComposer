class CreateRecipients < ActiveRecord::Migration
  def self.up
    create_table "recipients" do |t|
      t.column "project_id",   :integer,   :limit => 10,  :default => 0,    :null => false
      t.column "email",        :string,                   :default => "",   :null => false
      t.column "pass",         :string,    :limit => 50
      t.column "confirm_code", :string,    :limit => 50
      t.column "firstname",    :string,    :limit => 128
      t.column "surname",      :string,    :limit => 64
      t.column "surname2",     :string,    :limit => 64
      t.column "state",        :string,    :limit => 1,   :default => "P",  :null => false
      t.column "lang_pref",    :string,    :limit => 3,   :default => "ES", :null => false
      t.column "date_created", :datetime,                                   :null => false
      t.column "date_updated", :timestamp
    end
  end

  def self.down
    drop_table :recipients
  end
end
