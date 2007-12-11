class ContentController < ApplicationController
  
  skip_before_filter :login_required
  
  def page
    # show the requested page
    @bulletin = @project.bulletins.find_by_title(params[:bulletin_title])
    if @bulletin
      @content_page = @bulletin.content_pages.find_by_name(params[:page_name])
      
      if (@content_page)
        render :text => @content_page.render, :layout => 'content'
        return
      end
    end
    
    render :action => "invalid"
  end

end
