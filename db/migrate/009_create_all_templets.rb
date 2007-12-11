class CreateAllTemplets < ActiveRecord::Migration
  def self.up
    create_table "templet_layouts" do |t|
      t.column "templet_id",   :integer,                 :default => 0,             :null => false
      t.column "name",         :string,    :limit => 30, :default => "",            :null => false
      t.column "filetype",     :string,    :limit => 20, :default => "text/html",   :null => false
      t.column "charset",      :string,    :limit => 20, :default => "UTF-8", :null => false
      t.column "edit_as_raw",  :boolean,                 :default => false,         :null => false
      t.column "data",         :text,                    :default => "",            :null => false
      t.column "date_created", :datetime,                                           :null => false
      t.column "date_updated", :timestamp
    end
  
    create_table "templets" do |t|
      t.column "project_id",   :integer,                 :default => 0,     :null => false
      t.column "type",         :string,    :limit => 24
      t.column "type_code",    :string,    :limit => 1,  :default => "B",   :null => false
      t.column "name",         :string,    :limit => 50, :default => "",    :null => false
      t.column "subject",      :string
      t.column "static",       :boolean,                 :default => false, :null => false
      t.column "description",  :text,                    :default => "",    :null => false
      t.column "date_created", :datetime,                                   :null => false
      t.column "date_updated", :timestamp
    end
  end

  def self.down
    drop_table :templets
    drop_table :templet_layouts
  end
end
