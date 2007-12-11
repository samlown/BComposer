class TempletExporter
  attr_accessor :name
  attr_accessor :type, :filter
  attr_accessor :subject, :description
  attr_accessor :updated_on, :created_on
  attr_accessor :filetype, :charset

  @@basedir = 'db/templets/'

  def initialize(templet = nil, layout = nil)
  
    if (templet and layout)
      self.name = templet.name
      self.type = templet.type.to_s
      self.subject = templet.subject
      self.description = templet.description
      self.updated_on = templet.updated_on
      self.created_on = templet.created_on
      self.filetype = layout.filetype
      self.charset = layout.charset
      self.filter = layout.filter
    end
  end
  
  def update_templet( templet )
    attribs = {
      :name => self.name,
      :subject => self.subject,
      :description => self.description,
      :updated_on => self.updated_on,
      :created_on => self.created_on,
    }
    templet.update_attributes( attribs )
    # Variables that cannot be set using attributes!
    templet.type = self.type #.constantize
  end
  
  def update_layout( layout, file )
    layout.filetype = self.filetype
    layout.charset = self.charset
    layout.filter = self.filter
    File.open(file, "r") do | f |
      layout.data = f.read(100000)  # max 100KB
      layout.data = " " if (! layout.data)
    end
  end
  
  def self.load_and_store_templets
    Dir.foreach(@@basedir) do | file |
      next if file !~ /\.yml$/
      data = YAML.load_file(@@basedir + file)

      puts "Loading templet: " + data.name
      
      # try to find a local copy
      templet = Templet.find(:first, :conditions => ['project_id = 0 AND name = ?', data.name])
      templet = Templet.new if (! templet)
        
      data.update_templet(templet)
      templet.save
      
      layout = templet.templet_layouts.find_by_name('main')
      layout = templet.templet_layouts.build( :name => 'main' ) if (! layout)
      data.update_layout( layout, @@basedir + file.gsub(/yml$/, 'rhtml') )
      layout.save
    end
  
  end
  
  # Load and copy all the templets to the migration folder
  def self.save_templets
    Templet.find(:all, :conditions => ['project_id = 0']).each do | templet |
      layout = templet.templet_layouts.find(:first, :conditions => ['name = ?', 'main'])
      data = TempletExporter.new(templet, layout)
        
      filename = @@basedir + templet.name.downcase.gsub(/ /, '_')
      # prepare file
      File.open(filename + '.yml', "w") do | f |
        f.write( data.to_yaml )
      end
      File.open(filename + '.rhtml', "w") do | f |
        f.write( layout.data )
      end
      puts "Stored: "+filename
    end
  end
end