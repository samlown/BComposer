class Admin::FilesController < ApplicationController

  layout 'admin'

  verify :method => :post, :only => [ :add, :resize, :delete ],
         :redirect_to => { :action => :list }

  before_filter :skip_admin_flash
  
  before_filter :except => [ :list ] do | c |
    c.check_role(:edit_files, :back)
  end

  def index
    list
    render :action => 'list'
  end
  
  def list
    dir_path = current_path
    
    @mode = params[:mode] ? params[:mode].to_sym : :normal
    @update_field = params[:field]
    
    @edit_file = (params[:edit_file] ? params[:edit_file] : '')
    @resize_file = (params[:resize_file] ? params[:resize_file] : '')
    
    @dirs = []
    @files = []
    dir = Dir.new( dir_path )
    dir.entries.sort.each do | file |
      next if file !~ /^[^\.]/
      filestat = File.stat(dir_path + file)
      dim = nil
      if file =~ /\.(gif|png|jpe?g)$/
        if LibraryHelper.check_magick
          if img = Magick::Image.ping(dir_path + file).first
            dim = "#{img.columns}x#{img.rows}"
          end
        end
      end
      @dirs << { :name => file, :dir => true } if filestat.directory?
      @files << { :name => file,
            :size => filestat.size, :dim => dim,
            :url => BcomposerUrlWriter.instance.url_for_media(@project, (@path.size > 0 ? @path.join('/') + '/' : '') + file),
            :modified_on => filestat.ctime,
      } if not filestat.directory?
    end
    
    if request.xhr? or params[:ahr] or params[:ajx]
      render :partial => 'list', :layout => false
    elsif @mode == :popup
      render :action => 'list', :layout => 'admin_popup'
    else
      render :action => 'list'
    end
  end

  def add
    cur_path = current_path
    if not params[:directory_name].blank?
      add_dir( cur_path, params[:directory_name].gsub(/\./, '') )
    elsif not params[:upload_file].blank?
      add_file( cur_path, params[:upload_file] )
    end

    redirect_to :action=>'list', :path => @path.join('/'), :ahr => request.xhr?, :mode => params[:mode]
  end

  # Edit the provided file or directory name
  def edit
    cur_path = current_path
    dir = Dir.new( cur_path )
    if request.post?
      original_name = params[:original_file_name].gsub(/\.\./, '')
      file_name = params[:file_name].gsub(/\.\./, '')
      if (original_name.blank? or file_name.blank?)
        @edit_file = original_name
        flash[:warning] = _('Invalid filename')
      elsif (dir.entries.include? file_name)
        flash[:warning] = _('File with the same name already exists!')
      else
        FileUtils.mv(cur_path + original_name, cur_path + file_name)
        flash[:notice] = _('File name updated successfully!')
      end
    end
    redirect_to :action => 'list', :path => @path.join('/'), :ahr => request.xhr?, :mode => params[:mode]
  end

  def delete
    cur_path = current_path
    file = params[:file].gsub(/\.\./, '')
    if FileTest.exists? cur_path + file
      FileUtils.rm_r cur_path + file
      flash[:notice] = _('File removed successfully')
    else
      flash[:warning] = _('File does not exist to remove')
    end
    
    redirect_to :action => 'list', :path => @path.join('/'), :ahr => request.xhr?, :mode => params[:mode]
  end
  
  def resize
    cur_path = current_path
    
    file = params[:file].gsub(/\.\./, '')
    size = [ ]
    params[:size].split('x').each { |s| size << s.to_i }
    # re-write size, safely!
    size_str = size[0].to_s + 'x' + size[1].to_s
    
    if FileTest.exists? cur_path + file
      img = Magick::Image.read(cur_path + file).first
      img.resize_to_fit!(size[0], size[1])
      new_name = file.gsub(/\.(gif|png|jpe?g)$/, "_#{size_str}"+'.\1' )
      img.write( cur_path + new_name )
      flash[:notice] = _("Image resized correctly!")
    else
      flash[:warning] = _("Unable to find file!")
    end
    
    redirect_to :action => 'list', :path => @path.join('/'), :ahr => request.xhr?, :mode => params[:mode]
  end

  protected
  
  # Provide the current path and fill the @path variable 
  # with an array of entries for the current path.
  def current_path
    return @current_path if (@current_path)
    
    @current_path = @project.directory_path + '/'
    @path = Array.new
    @path += params[:path].split('/') if (params[:path])
    @path.each do | p |
      p.gsub!(/[(\.\.)\/\\]/, '') # prevent hacks!
      @current_path += p + '/'
    end
    
    return @current_path
  end
  
  def add_dir( cur_path, name )
    dir = Dir.new( cur_path )
    if dir.entries.include? name
      flash[:warning] = _("Directory already exists!")
    else
      if Dir.mkdir( cur_path + name )
        flash[:notice] = _("Directory created successfully.")
      else
        flash[:warning] = _("Unable to create directory!")
      end
    end
  end
  
  def add_file( cur_path, file )
    dir = Dir.new( cur_path )
    name = file.original_filename
    if dir.entries.include? name
      flash[:warning] = _("File with the same name already exists!")
    else
      begin
        File.open( cur_path + name, "w") do | f |
          f.write( file.read )
        end
      rescue
        flash[:warning] = _("An error occurred while saving the file:") + $!
        return
      end
      flash[:notice] = _("File save successfully!")
    end
  end
end
