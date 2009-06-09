# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base

  # do a permissions check for everything
  before_filter :configure_language
  before_filter :login_required
  before_filter :configure_charsets
  before_filter :require_project
  
  # init_gettext "bcomposer"
  
  def configure_language
    if (! params[:lang].blank?)
      cookies[:lang] = params[:lang]
    end
    I18n.locale = cookies[:lang] unless cookies[:lang].blank?
  end
  
  def configure_charsets
    #headers["Content-Type"] = "text/html; charset=ISO-8859-15"
    headers["Content-Type"] = "text/html; charset=UTF-8"
  end

  # If the user is not logged in, return to login form!
  def login_required
    if current_user
      return true
    end
    flash[:warning]='Please login to continue'
    # session[:return_to]=request.request_uri
    redirect_to :controller => "/admin/user", :action => "login"
    return false 
  end

  def current_user
    return @current_user if (@current_user)
    @current_user = session[:user]
  end
  
  def current_project
    @project
  end
  
  #
  # Try to load the project using available parameters
  #
  def load_project
    # check if already loaded
    return @project if (@project)
    
    if (params[:project_id]) 
      @project = Project.find(params[:project_id])
    elsif (params[:project_name])
      # try to use the name
      @project = Project.find(:first, :conditions => ["name = ?", params[:project_name]])
    elsif (request.domain =~ /^(www\.)?boletin-campusfaes.es$/ )
      @project = Project.find(:first, :conditions => ["name = ?", "Campus FAES"])
    end
    
    session[:project_id] = @project.id if @project
  end
  
  def load_project_from_session
    @project = Project.find(session[:project_id]) if (session[:project_id])
  end
  
  def require_project
    load_project
    load_project_from_session if ! @project
    if (! @project)
      redirect_to :controller => "/projects", :action => "list"
      return false
    end
    return true
  end

  
  #
  # Check for the page parameter, if present store in the session,
  # otherwise, force the parameter to something else.
  # Will only work with the same project!
  # 
  def remember_page( identifier )
    if params[:page]
      session[identifier] = params[:page]
    elsif session[identifier]
      params[:page] = session[identifier]
    end 
  end
  
#  def default_url_options(options)
#    if (@project and ! @project.new_record?)
#      return { :project_name => @project.name }
#    end
#  end

  ##
  # Check if the current user is an admin user, and if not, forward to base page.
  def require_admin
    if ! current_user.is_admin?
      redirect_to :controller=>'/projects', :action=>'list'
    end
  end
 
  def require_admin_or_project
    return true if (@project or current_user.is_admin?)
  end
 
  # 
  # Check if the current user and project has the specified role
  # permissions.
  # 
  # If redirect options are specified, the user will be redirected there.
  # 
  def check_role( role_symbol, redirect_options = nil )
    return true if current_user.is_admin?
    if (current_project and current_user )
      # cache the role object once its found
      @_role = current_project.user_roles.find_by_user_id(current_user.id) if ! @_role
      if (@_role.send( role_symbol.to_s ))
        return true
      end
    end
    flash[:error] = "Permission denied!"
    redirect_to redirect_options if redirect_options
    return false
  end
  
  
  # Prepare header and footer variables for use on internal pages 
  # used by the users
  def prepare_project_header_and_footer
    @header_text = @project.templets.find_by_name('PAGE_HEADER').render( @project )
    @footer_text = @project.templets.find_by_name('PAGE_FOOTER').render( @project )
  end
  
  # Skip the admin flash messages.
  # Useful when using ajax for updates.
  def skip_admin_flash
    @skip_admin_flash = true
  end
  
  # Render the provided page from the current project
  def render_page( page, page_opts = {}, render_opts = {} )
    render_opts.update( :layout => true ) if render_opts[:layout].nil?
    render_opts.update( :text => @project.templets.find_by_name(page).render( @project, page_opts ) )
    render render_opts
  end
  
end
