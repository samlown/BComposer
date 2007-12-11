#
# Liquid Entries
# 
# Finds the last section from the context and goes through each of its entries.
# 
# Does not require any additional parameters as the section is taken from
# the current section. It does however require that the section have been
# declared previously.
# 
class BcomposerLiquid::Tags::Entries < Liquid::Block

  def render( context )
    section = context.registers[:section]
  
    raise "No section defined!" if (! section)
    
    result = []
    
    entries = {
      'length' => section.entries.count,
    }
    
    section.entries.find(:all, :order => 'position ASC').each do | entry |
      context.stack do
        context['entry'] = BcomposerLiquid::Drops::Entry.new( entry )
        context.registers[:entry] = entry
        context['entries'] = entries
        
        result << render_all(@nodelist, context)
      end
    end
    result
  end

end

Liquid::Template.register_tag('entries', BcomposerLiquid::Tags::Entries)