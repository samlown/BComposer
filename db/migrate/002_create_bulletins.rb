class CreateBulletins < ActiveRecord::Migration
  def self.up
    create_table "bulletins" do |t|
      t.column "project_id",    :integer,                :default => 0,   :null => false
      t.column "templet_id",    :integer,                :default => 0,   :null => false
      t.column "title",         :string,                 :default => "",  :null => false
      t.column "subject",       :string
      t.column "notes",         :text
      t.column "rendered",      :text
      t.column "status",        :string,    :limit => 1, :default => "O", :null => false
      t.column "date_released", :datetime
      t.column "date_updated",  :timestamp
    end
  end

  def self.down
    drop_table :bulletins
  end
end
