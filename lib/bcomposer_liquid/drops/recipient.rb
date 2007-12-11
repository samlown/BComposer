class BcomposerLiquid::Drops::Recipient < Liquid::Drop
  
  def initialize( recip )
    @recip = recip
  end
  
  def before_method( method )
    if @recip.nil?
      'recipient.'+method
    elsif @recip.safe_method? method
      @recip.send( method )
    else
      ''
    end
  end

end