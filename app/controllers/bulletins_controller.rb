class BulletinsController < ApplicationController

  layout 'project'
  
  before_filter :prepare_project_header_and_footer

  skip_before_filter :login_required
  skip_before_filter :configure_charsets
  before_filter :configure_charsets, :except=>['show']

  def index 
    @bulletins = @project.bulletins.sent.paginate :per_page => 20, :page => params[:page], :order => 'date DESC',
        :include => :sections
    respond_to do | format |
      format.html { render :action => 'list' }
      format.xml { render :xml => @bulletins.to_xml( :except => [:rendered], :include => [ :sections ] )  }
    end
  end

  def list
    redirect_to :action => :index
  end
  
  def show
    layout_style = nil
    if (params[:layout])
      layout_style = params[:layout]
    end

    if params[:bulletin_title]
      @bulletin = @project.bulletins.find(:first, :conditions => ['title = ?', params[:bulletin_title]])
    elsif (params[:id])
      @bulletin = @project.bulletins.find(params[:id])
    end
    
    if (! @bulletin)
      flash[:error] = "Invalid Bulletin!"
      redirect_to :action => 'list'
      return
    end
    
    
    begin
      bl = @bulletin.layout(layout_style)
      headers["Content-Type"] = bl.filetype + "; charset=" + bl.charset
      render :text => bl.rendered, :layout => 'bulletin'
    rescue
      flash[:error] = 'A fatal error has occurred while compiling the temlpate!'+
            '<br />Please check the template and try again!<br />ERROR: '+$!
      redirect_to :action => 'list'
    end
  end
end
