
module BcomposerLiquid::LinkHelper

  def url_for_media( file )
    link_helper.url_for_media(find_project, file)
  end

  # Add the base url including domain for the requested file.
  # Also checks to ensure the provided file is not already
  # a complete url, in which case, nothing will be attached.
  def url_for(file)
    link_helper.url_for_media(file)
  end
  
  # If the provided link does not include the protocol,
  # assume it is a link to an internal page.
  def url_for_link( link )
    link_helper.url_for_link( find_project, :bulletin => find_bulletin, :link => link )
  end
  
  def url_for_page( page, layout = nil )
    link_helper.url_for_page( find_project, :bulletin => find_bulletin, :page_name => page, :layout => layout )
  end
  
  def url_for_bulletin_layout( layout )
    link_helper.url_for_bulletin( find_project, :bulletin => find_bulletin, :layout => layout )
  end
  
  def url_for_forward_page( page )
    link_helper.url_for_forward( find_project, :bulletin => find_bulletin, :page => page )  
  end
  
  ##########################################
  # LINK TO methods - include HTML output
  
  # Create a generic HTML link to the item specified
  def link_to( text, url, opts )
    res = "<a href=\"#{url}\""
    opts.each do | k, v |
      res += " k=\"#{v}\""
    end
    res += ">" + text + "</a>"
  end

  def link_to_media( text, url = nil, opts = {} )
     url = text if url.blank?
     link_to text, url_for_media( url ), opts
  end
  
  def link_to_print( text, opts = {} )
    link_to text, find_bulletin.print_url, opts
  end
  
  def link_to_page( text, url = nil, opts = {} )
    url = text if url.nil?
    link_to text, url_for_page( url ), opts
  end
  
  def link_to_bulletin( text, layout = nil, opts = {} )
    if layout
      link_to text, url_for_bulletin( layout ), opts
    end
  end
  
  def link_to_link( text, url = nil, opts = {} )
    url = text if url.nil?
    link_to(text, url_for_link( url ), opts)
  end
  
  protected

  def link_helper
    return @_link_helper if @_link_helper
    @_link_helper = BcomposerUrlWriter.new
  end
  
  # try to find the bulletin object, or raise an error 
  # if there isn't one.
  # The bulletin is returned.
  def find_bulletin
    if (@context.nil?)
      raise "No context object found, is Liquid running?"
    elsif (bulletin = @context.registers[:bulletin].nil?)
      raise "No bulletin object provided for links helper!"
    end
    bulletin
  end

  def find_project
    if (@context.nil?)
      raise "No context object found, is Liquid running?"
    elsif (! @context.registers[:project].nil?)
      @context.registers[:project]
    else
      # check for project in bulletin
      find_bulletin.project      
    end
  end
end