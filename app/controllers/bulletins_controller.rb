class BulletinsController < ApplicationController

  layout 'project'
  
  before_filter :prepare_project_header_and_footer

  skip_before_filter :login_required
  skip_before_filter :configure_charsets
  before_filter :configure_charsets, :except=>['show']

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @bulletin_pages, @bulletins = paginate :bulletins, :per_page => 20, :order => 'date DESC',
        :conditions => ['project_id = ? AND status = ?', @project.id, 'S'],
        :include => :sections
    respond_to do | format |
      format.html { render :action => 'list' }
      format.xml { render :xml => @bulletins.to_xml( :except => [:rendered], :include => [ :sections ] )  }
    end
  end
  
  def show

    layout_style = nil
    if (params[:layout])
      layout_style = params[:layout]
    end

    if params[:bulletin_title]
      @bulletin = @project.bulletins.find(:first, :conditions => ['title = ?', params[:bulletin_title]])
    elsif (params[:id])
      @bulletin = Bulletin.find(params[:id])
    end
    
    if (! @bulletin)
      flash[:error] = "Invalid Bulletin!"
      redirect_to :action => 'list'
      return
    end
    
    
    begin
      bl = @bulletin.layout(layout_style)
      @headers["Content-Type"] = bl.filetype + "; charset=" + bl.charset
      render :text => bl.rendered, :layout => 'bulletin'
    rescue
      flash[:error] = 'A fatal error has occurred while compiling the temlpate!'+
            '<br />Please check the template and try again!<br />ERROR: '+$!
      redirect_to :action => 'list'
    end
  end
end
