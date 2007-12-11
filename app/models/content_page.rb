class ContentPage < ActiveRecord::Base

  belongs_to :templet
  belongs_to :bulletin
  
  # acts_as_taggable :join_table => 'content_page_tags'
  
  validates_format_of :name, :with => /^[\d\w_\-]+$/
  validates_uniqueness_of :name, :scope => 'bulletin_id'
  
  def render( layout = nil )
    self.templet.render( self.bulletin, self, layout )
  end
  
end
