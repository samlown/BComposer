class CreateSections < ActiveRecord::Migration
  def self.up
    create_table "sections" do |t|
      t.column "bulletin_id",  :integer,                 :default => 0,  :null => false
      t.column "name",         :string,                  :default => "", :null => false
      t.column "title",        :text
      t.column "style",        :string,    :limit => 50
      t.column "description",  :text
      t.column "type",         :string,    :limit => 10
      t.column "link",         :string
      t.column "link_text",    :string
      t.column "date_created", :datetime,                                :null => false
      t.column "date_updated", :timestamp
    end
  end

  def self.down
    drop_table :sections
  end
end
