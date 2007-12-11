class BcomposerLiquid::Drops::Project < Liquid::Drop
  
  def initialize( project )
    @project = project
  end
  
  def before_method( method )
    if @project.safe_method? method
      @project.send( method )
    else
      ''
    end
  end

end