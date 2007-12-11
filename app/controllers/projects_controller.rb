class ProjectsController < ApplicationController

  layout 'project'

  skip_before_filter :login_required
  before_filter :prepare_project_header_and_footer

  def show
    render :text => @project.templets.find_by_name('PAGE_PROJECT').render( @project ), :layout => true
  end
  
  def list
  
  end

end
