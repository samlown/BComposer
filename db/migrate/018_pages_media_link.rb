class PagesMediaLink < ActiveRecord::Migration
  def self.up
    add_column :content_pages, :media_url, :string, :null => true
  end

  def self.down
    remove_column :content_pages, :media_url
  end
end
