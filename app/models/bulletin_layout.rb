#
# Bulletin Layout
# 
# A caching object that stores a copy of the Bulletin at the moment it is sent.
# 
# This table is losely joined with the template layout through the name, but by its 
# nature, is not directly linked through ids.
# 
# The idea with this class is to maintain a store of bulletins that have been sent
# that cannot be modified by changing the templates.
# 
# Also included are functions that help with the presentation of the bulletin, 
# and for ease of use to create. Additional helper HTML code will only be added
# if the filetype is set to text/html and if the BulletinLayout is set to edit 
# mode.
#
class BulletinLayout < ActiveRecord::Base

  belongs_to :bulletin
  
  # Variables used during rendering
  attr_accessor :recipient
  
  # 
  # provide the base layout object of the bulletin before it is rendered!
  # 
  def layout

    raise "Missing bulletin for layout object!" if (! self.bulletin)
  
    raise "Missing layout style/name for layout object!" if (! self.name)

    # assume everything prepared if this is already set (caching!)
    return @layout if (@layout)

    # Load layout from the database
    while (! @layout)
      @layout = TempletLayout.find(:first, 
          :conditions => ['templet_id = ? AND name = ?', self.bulletin.templet_id, self.name ])
      if !@layout and self.name == 'print'
        # set to main, if print layout not found
        self.name = 'main'
      elsif not @layout
        raise "Invalid layout selected!" if (! @layout)  
      end
    end
    
    
    # copy the details accross for the layout
    self.filetype = @layout.filetype
    self.charset = @layout.charset
     
    return @layout
  end
  
  def render(recip = nil, cont = nil)

    raise "Missing bulletin for layout object!" if (! self.bulletin)

    # We add some extra filter type checking here as it determines the 
    # type of data used, i.e. if we need a binding.
    if layout.is_filter? 'ERB'
      @recipient = (recip) ? recip : Recipient.new 
      @controller = cont
    
      @_erbout = ''
      logger.info("Rendering with ERB template!")
      self.rendered = layout.render(binding)
    else
      # use liquid!
      logger.info("Rendering with Liquid template system!")
      self.rendered = layout.render_liquid( :recipient => recip, :bulletin => self.bulletin, :controller => cont )
    end
  end
  
  def render_and_save
    render
    save
  end
  
  # Rather than retrieving the normal rendered data, pass it though a second
  # level filter.
  # 
  # The templet_layout class is used, which requires a pre-rendered copy 
  # otherwise it will render a fresh version.
  def rendered_with_filter( subscription )
    render( subscription.recipient ) if (! rendered) # prepare rendered if not already done!
    layout.rendered = rendered # copy our version
    layout.rendered_with_filter( :subscription => subscription, :bulletin => self.bulletin,
        :recipient => subscription.recipient, :project => self.bulletin.project)
  end
  
  # protected
  
  include BulletinRenderMethods
  include BulletinTextHelper
  
end
