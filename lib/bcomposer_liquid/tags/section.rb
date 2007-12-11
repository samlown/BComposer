#
# = Bcomposer Liquid Section block
# 
# Provides a section object and hash for the current block.
# 
# If no section is found matching the provided name and a controller
# object is provided in the context registers, then a new section 
# and sample entry will be created with the same name. This makes
# producing new, empty, bulletins much quicker and easier.
# 
class BcomposerLiquid::Tags::Section < Liquid::Block

  Syntax = /(#{Liquid::QuotedFragment}+)/

  def initialize( tag_name, markup, tokens )

    if markup =~ Syntax
      @section_name = $1.gsub(/'/, '')
    else 
      raise "Invalid section tag"
    end
    
    super
  end

  def render( context )
    section = context.registers[:bulletin].sections.find_by_name( @section_name )
    if (! section)
      # have a quick search for the controller, if there isn't one, provide an error
      if (context.registers[:controller])
        section = build_new_section( context, @section_name )
      else
        raise "Invalid section name: '#{@section_name}'!"
      end
    end
    
    context.stack do
      context['section'] = BcomposerLiquid::Drops::Section.new( section )
      context.registers[:section] = section
      # context['entries'] = section.entries
      super( context )
    end
    
  end

  protected

  def build_new_section( context, name )
    bulletin = context.registers[:bulletin]
    section = bulletin.sections.build( :name => name )
    section.set_defaults
    if (! section.save)
      raise "Unable to create new section!"
    end
    # add an entry too
    e = section.entries.build()
    e.set_defaults
    e.save
    section
  end
end

Liquid::Template.register_tag('section', BcomposerLiquid::Tags::Section)