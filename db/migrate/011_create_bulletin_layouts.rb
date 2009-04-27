class CreateBulletinLayouts < ActiveRecord::Migration
  def self.up
    create_table "bulletin_layouts" do |t|
      t.column "bulletin_id",  :integer,                 :default => 0,  :null => false
      t.column "name",         :string,    :limit => 30, :default => "", :null => false
      t.column "filetype",     :string,    :limit => 20, :default => "", :null => false
      t.column "charset",      :string,    :limit => 20, :default => "", :null => false
      t.column "rendered",     :text,                    :default => "", :null => false
      t.column "date_updated", :timestamp
    end
  
    add_index "bulletin_layouts", ["bulletin_id", "name"], :name => "bulletin_id_name", :unique => true
  end

  def self.down
    drop_table :bulletin_layouts
  end
end
