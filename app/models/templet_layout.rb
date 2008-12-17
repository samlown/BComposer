class TempletLayout < ActiveRecord::Base
  belongs_to :templet

  # Provide access to some text helper functions.
  # This is for ERB support only!
  include BulletinTextHelper if ENABLE_ERB_LAYOUTS

  attr_accessor :rendered
  attr_protected :filter

  @@valid_filters = ['liquid'] + (ENABLE_ERB_LAYOUTS ? ['ERB'] : [])
  
  @@valid_filetypes = ['text/html', 'text/plain']

  def charset
    c = super()
    return (c.blank? ? 'UTF-8' : c)
  end

  def is_valid_filter? f
    @@valid_filters.include? f
  end

  def is_filter? name
    (self.filter == name)
  end
  
  def valid_filters
    @@valid_filters
  end
  def self.valid_filetypes
    @@valid_filetypes
  end

  def save
    if new_record? and filter.blank?
      self.filter = 'liquid'
      self.charset = 'UTF-8'
      self.data = " " if self.data.blank?
    end
    super
  end


  def render( opts = nil )
    if filter.blank?
      self.rendered = data
    elsif (is_filter? 'ERB' and (opts.nil? or ! opts.is_a? Hash)) and ENABLE_ERB_LAYOUTS
      render_erb( opts )
    else
      render_liquid( opts )
    end
    # if we're dealing with a plain text layout, remove HTML tags and fix links
    if filetype == 'text/plain'
      self.rendered = html_to_text( self.rendered )
    end
    return self.rendered
  end

  #
  # Provide a rendered copy of this layout.
  # 
  # The provided binding object is used to setup the environment used for
  # rendering if that is required.
  # 
  def render_erb( bind = nil )
    raise "No data to render!" if (! data)
    @_erbout = ""
    self.rendered = ERB.new(data, nil, nil, '@_erbout').result( bind )
  end

  # 
  # Render the template using the liquid template system.
  # The bulletin, recipient, project, etc. fields should be provided in the
  # assigns hash. The registers hash is used for defining items that the template
  # will not have direct access to, such as a controller.
  # 
  # The loader parameter can be either a pre-pared BcomposerLiquid::Loader object
  # or a hash so the loader can be instantiated automatically.
  # 
  def render_liquid( loader )
    raise "No data to render!" if (! data)
    if loader.is_a? Hash
      loader = BcomposerLiquid::Loader.new( loader )
    end
    raise "render_liquid: Invalid loader object!" if ! loader.is_a? BcomposerLiquid::Loader
    
    # parse and render the template
    temp = Liquid::Template.parse( data )
    self.rendered = temp.render( loader.assigns, {:filters => loader.filters, :registers => loader.registers } )
  end

  def rendered
    render if ! @rendered
    @rendered
  end

  # Render the template but use a filter. 
  # 
  # Strings which match the pattern: /%(\w+)\.([a-z0-9_]+)%/
  # are split into two parts, the object name and the method to call.
  # 
  # Only methods that pass the object's "safe_method?" method will be
  # allowed to be called.
  # 
  # If 'stats_link' is recognised as the method, the current bulletin
  # is automatically added in the call.
  # 
  def rendered_with_filter( objects )
    render( objects ) if (! @rendered)
    new_rendered = rendered.gsub(/%((\w+)\.)?([a-zA-Z0-9_]+)%/) do | match |
      if ($1)
        if (obj = objects[$2.to_sym])
          if ($3 == 'stats_url' and ! objects[:bulletin].nil?)
            obj.stats_url( objects[:bulletin] )
          else
            (obj.safe_method? $3) ? obj.send($3) : match
          end
        else
          match
        end
      else
        (objects[:bulletin]) ? BcomposerUrlWriter.instance.url_for_page(
                objects[:bulletin].project, :bulletin => objects[:bulletin], :page_name => $3 ) : match
      end
    end
    return new_rendered
  end

end
