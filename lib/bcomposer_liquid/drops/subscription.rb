# 
# Liquid Subscription Drop
# 
# Doesn't really do very much but is here none the less.
#
class BcomposerLiquid::Drops::Subscription < Liquid::Drop
  
  def initialize( subscription )
    @subscription = subscription
  end
  
  def before_method( method )
    if @subscription.safe_method? method
      @subscription.send( method )
    else
      "INVALID: "+method
    end
  end

end