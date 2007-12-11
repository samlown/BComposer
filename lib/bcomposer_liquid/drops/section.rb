class BcomposerLiquid::Drops::Section < Liquid::Drop
  
  def initialize( section )
    @section = section
  end
  
  def before_method( method )
    if @section.attribute_names.include? method
      @section.send( method )
    else
      ''
    end
  end

end