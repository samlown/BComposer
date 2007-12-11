class BcomposerLiquid::Drops::Entry < Liquid::Drop
  
  def initialize( entry )
    @entry = entry
  end
  
  def before_method( method )
    if @entry.attribute_names.include? method
      @entry.send( method )
    else
      ''
    end
  end

end