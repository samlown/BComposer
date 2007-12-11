class Templet < ActiveRecord::Base
  
  belongs_to :project
  
  has_many :bulletins
  
  has_many :templet_layouts, :dependent => :destroy do
    # Override the normal find by name so that if the requested
    # layout is not found, the default is provided
    def find_by_name( name )
      name = 'main' if (name.blank?)
      layout = nil
      while (! layout)
        layout = find(:first, :conditions => ['name = ?', name])
        if (name != 'main' and ! layout)
          name = 'main'
        else
          return layout
        end
      end
    end
    
    def default
      find_by_name( nil )
    end
  end
  
  @@valid_types = [
    'Bulletin',
    'Email',
    'Page',
  ] + (ENABLE_CONTENT_PAGES ? [ 'ContentTemplet' ] : [ ])
  
  def valid_types
    @@valid_types
  end
  
  # Only find templates with no project
  # when the find_by_name method is used
  def self.find_by_name( name )
    find(:first, :conditions => ['project_id = 0 AND name = ?', name])
  end
  
  def type_name
    if (self.is_a? Email)
      'Email'
    elsif (self.is_a? Page)
      'Page'
    elsif (self.is_a? ContentTemplet)
      'ContentTemplet'
    else 
      'Bulletin'
    end
  end
  
  def type_name=(name)
    # nothinc
  end

  # used to make it easier to create a template 
  # of a specific type
  def self.new_of_type(type, attributes = nil)
    if (type)
      attributes[:type_name] = nil
      if (type == 'Email')
        r = Email.new(attributes)
      elsif (type == 'Page')
        r = Page.new(attributes)
      elsif (type == 'ContentTemplet')
        r = ContentTemplet.new(attributes)
      else
        r = Templet.new(attributes)
      end
    end
    return r
  end
  
  # Clone and save onself with all sub layouts
  def duplicate
    # copy self, save, then copy layouts
    templet = clone()
    templet.save
    templet_layouts.each do | layout |
      t = templet.templet_layouts.build( layout.attributes )
      t.filter = layout.filter
      t.charset = layout.charset
      t.save
    end
    return templet
  end
  
  # Produce a selection of templates available for a bulletin
  # in the specified project.
  def self.find_for_bulletin( project )
    find(:all, :conditions => ["(project_id = ?) AND (type = 'Templet' OR type IS NULL)", project.id])
  end
  
end
