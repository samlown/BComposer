#
# Extends the templet to provide the ability to generate email messages.
#
# Email messages allow the user to create a one-off email that does not require 
# the complexity of a bulletin.
#
class Email < Templet

  # generic accessor for links
  attr_accessor :link
  
  # prepare a special class used for useful funtions/variables
  class EmailParameters
    attr_accessor :forward_url, :sender, :comment
    def initialize( options )
      if (options)
        self.forward_url = options[:forward_url]
        self.comment = options[:comment]
        self.sender = options[:sender]
      end
    end
    
    def safe_method?( method )
      self.methods.include? method
    end
  end

  # Options
  # * subscription: object
  # Additional options passed to EmailParameters class
  # 
  # If used in block mode, each templet is looped through except the print layout
  # which is useful for sending emails
  def render( options = { } )
    raise "No subscription for email!" if (! options[:subscription])
    params = EmailParameters.new( options )
    options.update( :params => params, :project => options[:subscription].project,
            :recipient => options[:subscription].recipient )
 
    if options[:layout].blank?   
      if block_given?
        templet_layouts.each do | layout |
          next if layout.name == 'print'
          rendered = layout.rendered_with_filter( options )
          content_type = layout.filetype + "; charset=" + layout.charset
          yield rendered, content_type
        end
        return
      else
        layout = templet_layouts.default
      end
    else
      layout = templet_layouts.find_by_name(options[:layout])
    end
    
    rendered = layout.rendered_with_filter( options )

    if block_given?
      content_type = layout.filetype + "; charset=" + layout.charset
      yield rendered, content_type
    else
      return rendered
    end
  end

end