#
# Extends the templet to provide templates for content pages
# 
# 
#
class ContentTemplet < Templet

  attr_accessor :bulletin
  attr_accessor :content_page

  def render( bulletin, content_page, layout )
    layout = templet_layouts.find_by_name( layout )
    self.bulletin = bulletin
    self.content_page = content_page
    # ERBs must be sorted first
    layout.render( binding ) if layout.is_filter? 'ERB'
    layout.rendered_with_filter(:content_page => self.content_page, :project => bulletin.project, :bulletin => bulletin)
  end
  
  protected
  
  #
  # Include the Bulleting Render methods, although edit functionality
  # will never be used.
  #
  include BulletinRenderMethods
  
end