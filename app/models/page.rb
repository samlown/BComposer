#
# Extension of a Template for Pages used when preseting things to the user.
#
class Page < Templet

  # prepare a special class used for useful funtions/variables
  class PageParameters
    
    attr_accessor :bulletin_name, :page_name
  
    def initialize( options )
      if (options)
        self.bulletin_name = options[:bulletin_name]
        self.page_name = options[:page_name]
        # remove old entries as they are no longer needed
        options.delete( :bulletin_name )
        options.delete( :page_name )    
      end
    end
    
    def safe_method?( method )
      methods.include? method
    end
  end

  # Render the page ready to be output. Options include:
  #   * bulletin_name
  #   * page_name
  #   * recipient - object used for forms that make use of the recipient
  def render( project, options = { } )
    page_params = PageParameters.new( options )
    layout = templet_layouts.default
    options.update( :project => project, :params => page_params )
    @recipient = options[:recipient] if options[:recipient]
    if layout.is_filter? 'ERB'
      layout.render( binding )
    end
    layout.rendered_with_filter( options )
  end
  
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::FormHelper
  
end