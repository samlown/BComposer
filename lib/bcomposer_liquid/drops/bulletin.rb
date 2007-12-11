class BcomposerLiquid::Drops::Bulletin < Liquid::Drop
  
  def initialize( bulletin )
    @bulletin = bulletin
  end
  
  def before_method( method )
    if @bulletin.safe_method? method
      @bulletin.send( method )
    else
      ''
    end
  end

end