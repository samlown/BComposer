module ContentHelper

  def base_url
    # return the base url for this project
    @project.domain + @project.directory_url + '/'
  end
  
  # Add the base url including domain for the requested file.
  # Also checks to ensure the provided file is not already
  # a complete url, in which case, nothing will be attached.
  def url_for_file(file)
    (file =~ /^(http:\/\/|\/)/i) ? file : base_url + file if file
  end

end