class BcomposerLiquid::Drops::ContentPage < Liquid::Drop
  
  def initialize( page )
    @page = page
  end
  
  def before_method( method )
    if @page.attribute_names.include? method
      @page.send( method )
    else
      'INAVLID: '+method
    end
  end

end