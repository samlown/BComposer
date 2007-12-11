#
# Liquid Drop to handle a parameters object.
# 
# Parameter classes should already be safe, so their
# methods can be called directly without security problems.
# In effect, these drops are just wrappers to support 
# liquid templates.
# 
class BcomposerLiquid::Drops::Params < Liquid::Drop
  
  def initialize( params )
    @params = params
  end
  
  def before_method( method )
    @params.send( method )
  end

end