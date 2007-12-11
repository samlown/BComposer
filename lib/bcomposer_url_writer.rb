#
# A set of functions used to generate URLs to internal areas of bcomposer.
# 
# This is needed as both models and controllers require access to these 
# links.
# 
class BcomposerUrlWriter

  include ActionController::UrlWriter

  @@instance = nil

  # Create an instance of the class so that calls can be made
  # to the mothods
  def self.instance
    return @@instance if ! @@instance.nil?
    @@instance = new
  end
  
  # Setup the default url options
  # based on the project provided.
  # Should be run for each function in this module that uses
  # url_for.
  def setup_project_urls( project )
    # only run the setup once for the provided project
    return if @_project == project
    @_project = project
    # set up the base domain
    if project.domain =~ /^((https?):\/\/)?([^\:\s]+)(\:(\d+))?/
      default_url_options[:protocol] = $2 if $1
      default_url_options[:host] = $3
      default_url_options[:port] = $5 if $4
    end
  end
  


  # The base url for the project where user supplied 
  # files are read from
  def url_for_project_directory( project, options = nil )
    # setup_project_urls( project )
    # return the base url for this project
    project.domain + project.directory_url
  end
  
  # Provide the URL used to access media files stored in the 
  # project's base directory.
  def url_for_media( project, file )
    if (file)
      (file =~ /^(http:\/\/|mms:|\/)/i ? file : url_for_project_directory( project ) + '/' + file )
    end
  end
  
  # If the provided link does not include the protocol,
  # assume it is a link to an internal page.
  # Requires:
  # * bulletin: for when a page link
  # * link: URL or name of page
  def url_for_link( project, opts )
    if (opts[:link])
      (opts[:link] =~ /^(https?:\/\/|\/)/i) ? opts[:link] : url_for_page( project, opts.update(:page_name => opts[:link]) )
    end
  end
  
  # Expects:
  # * bulletin: bulletin object that the page belongs to
  # * page_name: name of the page
  # * layout: (optional) name of layout to use
  def url_for_page( project, opts )
    setup_project_urls( project )
    if (opts[:page_name])
      raise "No bulletin provided!" if (! opts[:bulletin])
      url_for :controller => 'content', :action => 'page',
          :project_name => project.name, 
          :bulletin_title => opts[:bulletin].title,
          :page_name => opts[:page_name],
          :layout => opts[:layout]
      
    end
  end
  
  def url_for_print( project, opts )
    url_for_bulletin( project, opts.update(:layout => 'print'))
  end
  
  # Expects:
  # * bulletin: object
  # * layout: optional name
  def url_for_bulletin( project, opts )
    setup_project_urls( project )
    raise "No bulletin provided!" if (! opts[:bulletin])
    url_for :controller => 'bulletins', :action => 'show',
      :project_name => project.name, 
      :bulletin_title => opts[:bulletin].title,
      :layout => opts[:layout]
  end

  # Expects the name of the project, and an object or name that will be forwarded.
  # Options:
  #   :bulletin - must be provided as an object
  #   :page  - Either a string or page object
  def url_for_forward( project, opts )
    setup_project_urls( project )
    raise "No Bulletin" if opts[:bulletin].nil?
    # if a page is provided, assume we want to forward to a page
    if opts[:page]
      url_for( :controller => 'forward', :action => 'page',
          :project_name => project.name,
          :bulletin_title => opts[:bulletin].title,
          :page_name => (opts[:page].is_a? String ? opts[:page] : opts[:page].name)
      )
    elsif opts[:bulletin]
      url_for( :controller => 'forward', :action => 'bulletin',
        :project_name => project.name, :bulletin_title => opts[:bulletin].title )
    end
  end
  
end
