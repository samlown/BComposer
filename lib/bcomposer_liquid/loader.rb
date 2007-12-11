module BcomposerLiquid

  # = Bcomposer Liquid Loader class
  # 
  # Used for loading and creating the necessary environment for
  # the correct execution of Liquid templates.
  # 
  # When instantiated, the bulletin object must be provided in the options.
  # 
  class Loader
    
    attr_reader :assigns, :filters, :registers
    
    # Upon instatiation of the loader set instance variables
    # that will later be used to correctly render the Liquid 
    # template.
    def initialize( opts = {} )
      @assigns = {}
      @filters = [ BulletinTextHelper, ActionView::Helpers::FormHelper, ActionView::Helpers::DateHelper,
        ActionView::Helpers::FormOptionsHelper, ActionView::Helpers::FormTagHelper ]
      @registers = {}
      if ! opts[:bulletin].nil? and opts[:project].nil?
        opts[:project] = opts[:bulletin].project
      end
      opts.each do | k, v |
        if [:controller, :bulletin, :project].include? k
          @registers[k] = v
          next unless [:bulletin, :project].include? k
        end
        begin
          drop = ('bcomposer_liquid/drops/'+k.to_s).camelize.constantize
          @assigns[k.to_s] = drop.new( v )
        rescue
          puts "ERROR: BcomposerLiquid::Loader#prepare: Invalid drop! "+$!
        end
      end
      @filters << BcomposerLiquid::LinkHelper
    end
        
  end

end