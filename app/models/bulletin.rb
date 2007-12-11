require 'erb'

class Bulletin < ActiveRecord::Base

  belongs_to :project
  belongs_to :templet
  has_many :sections, :dependent => :destroy
  has_many :recipient_receipts, :dependent => :delete_all, :extend => BulletinRecipientStatistics
  has_many :bulletin_layouts, :dependent => :delete_all
  has_many :content_pages, :dependent => :destroy
  
  validates_uniqueness_of :title, :scope => 'project_id'
  
  @@status_values =  {
      'O' => 'Open',
      'P' => 'Pending', 
      'T' => 'Sending',
      'S' => 'Sent',
      'E' => 'Error',
  }
  
  def is_status(status)
    if (self.status == status) or (@@status_values[self.status] == status)
      return true
    end
    return false
  end
  
  #
  # get the text version of the status
  #
  def status_text
    return @@status_values[self.status]
  end
  
  def full_title
    self.project.name + ' - ' + self.title
  end
  
  # Provide access to the bulletin's recipients.
  # A filter is always used on the results, as such this result
  # set is read-only. Management of the recipients should be done
  # through the normal project.recipients set.
  def subscriptions
    self.project.valid_subscriptions.find(:all, :conditions => self.filter_conditions)
  end
  
  def subscription_count
    self.project.valid_subscriptions.count(:conditions => self.filter_conditions)
  end
  
  
  # Set the filter for the list of recipients for this bulletin.
  # The filter is stored as a YAML hash inside the filter text field.
  def filter=( opts )
    self.filter_raw = ( opts.blank? ? nil : opts.to_yaml )
  end
  
  # Return a hash of data
  def filter
    f = self.filter_raw
    YAML.load(f) if ! f.nil?
  end
  
  # Return an array of the current filter that can be used directly
  # in a find under the conditions parameter.
  def filter_conditions
    f =  self.filter
    if (f.is_a? String)
      # plain Jane string, set by admin no doubt, return as is
      # and hope they know what they are doing!
      return ["( " + f + ")" ]
    elsif (f.is_a? Hash)
      # TODO - implement Hash version of filter
    end
    return nil
  end
  
  # override the date method to allways provide something if empty!
  # (This is a consequence of migration 30)
  def date
    d = super
    (d.nil? ? self.date_released : d)
  end
  
  # Check if the provided method is safe and typically just provides information.
  # This is meant for use in templates to confirm that an action is okay.
  def safe_method?( method )
    return true if attribute_names.include? method
    return true if ['full_title', 'print_url', 'forward_url', 'self_url'].include? method
    return false
  end

  #
  # Duplicate a bulletin and important data.
  # 
  # The title is automatically changed to maintain its uniqueness
  #
  def duplicate
    newb = self.clone
    newb.status = 'O'
    newb.rendered = nil
    newb.date_released = nil
    
    # alter name
    newb.title = title + ' copy'
    unique = false
    index = 1
    while not unique
      if (Bulletin.find_by_title(newb.title))
        newb.title = title + ' copy ' + index.to_s
        index += 1
      else
        unique = true
      end
    end
    
    if newb.save
      # go through each section
      self.sections.each do | section |
        newsec = section.clone
        newsec.bulletin = newb
        if newsec.save
          # go through each entry
          section.entries.each do | entry |
            newentry = entry.clone
            newentry.section = newsec
            newentry.save
          end
        end
      end
      # now copy the pages !
      self.content_pages.each do | page |
        newb.content_pages.create( page.attributes )
      end
      return newb
    else
      return
    end
  end


  #
  # Provide a pre-rendered copy of the requested layout
  # in the form of a BulletinLayout object.
  #  
  # The copy produced is based on the current status of the bulletin.
  # If the bulletin is open, then a fresh copy will always be provided.
  # In all other states, a pre-stored copy will be loaded with the
  # exception of two special cases:
  # 
  # * A pre-rendered copy does not exist, in which case the 
  # generate_all method will be called. This does not normally happen!
  # * While the bulletin is in a 'sending' state, and the parent template
  # is set to non-static.
  # 
  # If a recipient is provided, the produced bulletin will always pass through a
  # second phase to replace special template fields which may have 
  # been included in database values.
  # 
  def layout(layout_style = nil, recipient = nil)
    # use default layout, if none provided
    layout_style = 'main' if (! layout_style)
   
    # check the status to decide what to provide
    if ! is_status 'Open'
      if (! (is_status 'Sending' and ! templet.static))
        # Layouts cache
        @layouts = Hash.new if (! @layouts)
        
        if @layouts[layout_style]
          bl = @layouts[layout_style] 
        else
          # find a saved copy
          bl = self.bulletin_layouts.find(:first, :conditions => ['name = ?', layout_style])
          if (! bl)
            self.render_and_save_layouts
            # find again
            bl = self.bulletin_layouts.find(:first, :conditions => ['name = ?', layout_style])
          end
          @layouts[layout_style] = bl
        end
      elsif is_status 'Sent'
        bl = self.bulletin_layouts.find(:first, :conditions => ['name = ?', layout_style])
      end
    end
    
    if (! bl)
      bl = fresh_layout(layout_style)
      bl.render( recipient )
    end
      
    return bl
  end
  
  def layout_for_editing( layout_style, controller, recipient = nil )
    raise "Layout cannot be edited if bulletin is not open!" if (! is_status 'Open')
    bl = fresh_layout(layout_style)
    bl.render(recipient, controller)
    return bl
  end
  
  # 
  # Render each layout and save!
  # 
  def render_and_save_layouts
    self.templet.templet_layouts.each do | layout |
      bl = self.bulletin_layouts.build :name => layout.name
      bl.render_and_save
    end
  end
  
  #
  # remove all pre-rendered objects
  #
  def clear_rendered
    self.bulletin_layouts.clear
  end
  
  
  #######
  # URL Handling methods
  # 
  #  - Urls configured from here
  #  - each method set in safe_method? method
  #  
  def forward_url
    BcomposerUrlWriter.instance.url_for_forward( self.project, :bulletin => self )
  end
  
  def print_url
    self.self_url( :layout => 'print' )
  end
  
  # Provide a URL to self
  # Options:
  #   :layout => Layout to use to present bulletin
  def self_url( opts = { } )
    BcomposerUrlWriter.instance.url_for_bulletin( self.project, :bulletin => self, :layout => opts[:layout] )
  end
 
  protected
  
  # 
  # Provide a layout that has not yet been rendered
  # 
  def fresh_layout(layout_style)
    layout_style = (layout_style) ? layout_style : 'main'
    @fresh_layout = Hash.new if (! @fresh_layout)
    return @fresh_layout[layout_style] if @fresh_layout[layout_style]
    bl = BulletinLayout.new
    bl.bulletin = self
    bl.name = layout_style
    @fresh_layout[layout_style] = bl
  end
end
