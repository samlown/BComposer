#
# Link table between Content Pages and Tags
class CreateContentPageTags < ActiveRecord::Migration
  def self.up
    create_table(:content_page_tags, :id => false) do |t|
      t.column :content_page_id, :integer, :null => false
      t.column :tag_id, :integer, :null => false
    end
  end

  def self.down
    drop_table :content_page_tags
  end
end
