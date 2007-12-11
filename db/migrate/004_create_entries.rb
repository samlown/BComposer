class CreateEntries < ActiveRecord::Migration
  def self.up
    create_table "entries" do |t|
      t.column "section_id",   :integer,                 :default => 0,  :null => false
      t.column "title",        :text,                    :default => "", :null => false
      t.column "subtitle",     :text
      t.column "style",        :string,    :limit => 50
      t.column "body",         :text
      t.column "image_link",   :string
      t.column "image_text",   :text
      t.column "link",         :string
      t.column "link_text",    :string
      t.column "position",     :integer,   :limit => 6,  :default => 0,  :null => false
      t.column "date_created", :datetime,                                :null => false
      t.column "date_updated", :timestamp
    end
  end

  def self.down
    drop_table :entries
  end
end
