class Admin::UserController < ApplicationController

  layout 'admin'

  # override default login
  skip_before_filter :login_required
  before_filter :login_required, :only=>['change_password', 'hidden', 'list']
  skip_before_filter :require_project
  before_filter :require_project, :only=>['change_password', 'list']

  def login
    if current_user
      # redirect if they are already logged in!
      redirect_to admin_projects_url
      return
    end
    if request.post?
      if session[:user] = User.authenticate(params[:user][:name], params[:user][:password])
        flash[:notice]  = _("Login successful")
        redirect_to admin_projects_url
      else
        flash[:warning] = _("Login unsuccessful")
      end
    end
  end

  def logout
    session[:user] = nil
    flash[:notice] = _('Logged out')
    redirect_to :action => 'login'
  end

  def change_password
    @user=session[:user]
    if request.post?
      @user.update_attributes(:password=>params[:user][:password], 
                :password_confirmation => params[:user][:password_confirmation])
      if @user.save
        flash[:notice]= _("Password Changed")
      end
    end
  end

  def welcome
    u = session[:user]
    redirect_to admin_projects_url
  end

  def hidden
  end
   
  def list
    
  end
    

end
