class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table "projects" do |t|
      t.column "name",              :string,    :limit => 50,  :default => "", :null => false
      t.column "sender",            :string,    :limit => 100, :default => "", :null => false
      t.column "report_recipients", :text
      t.column "domain",            :string
      t.column "description",       :text
      t.column "default_lang",      :string,    :limit => 3,   :default => "", :null => false
      t.column "date_updated",      :timestamp
    end
  end

  def self.down
    drop_table "projects"
  end
end
