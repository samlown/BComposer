# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  #
  # HTML editor box helper function
  # 
  def fckeditor_text_area(object, method, options = {}, fckoptions = {})
    
    # set defaults when no fckoptions set
    if (! fckoptions[:width])
      fckoptions[:width] = "100%"
    end
    if (! fckoptions[:height]) 
      fckoptions[:height] = "250"
    end
    if (! fckoptions[:toolbar])
      fckoptions[:toolbar] = "BComposerEntry"
    end

    txt_opts = "'" + object + "[" + method + "]'" +
      ", '"+fckoptions[:width]+"', '"+fckoptions[:height]+"', '"+fckoptions[:toolbar]+"'"
    
    text_area(object, method, options ) +
    javascript_tag( "var oFCKeditor = new FCKeditor(" + txt_opts + "); oFCKeditor.ReplaceTextarea()" )
  end

  def page_selector(pager, link_opts = {})
    out = "<br/><div>"

    # copy link options
    opts = link_opts

    last = pager.current.offset + pager.items_per_page
    last = pager.item_count if (last > pager.item_count)
    
    out += link_to_if(pager.current.previous, _('prev'), link_opts.update( {:page => pager.current.previous } ) )+' '
    
    if (pager.page_count > 1)
      
      pager.each do |p|
        # skip all but first few
        diff = pager.current.number - p.number
        if (diff.abs > 4)
          out += link_to(pager.first.number.to_s, link_opts.update( {:page => pager.first } ) ) + ' ... ' if pager.first == p
          out += ' ... ' + link_to(pager.last.number.to_s, link_opts.update( {:page => pager.last } ) ) + ' ' if pager.last == p

        elsif (pager.current.number == p.number)
          out += '<span style="font-size: 110%; padding: 1px; border: 1px black solid;"><b>' + p.number.to_s + '</b></span> '

        else 
          out += link_to(p.number.to_s , link_opts.update( {:page => p} )) + ' '

        end
      end
    end
    
    out += link_to_if(pager.current.next, _('next'), link_opts.update( {:page => pager.current.next} ))
    
    out += '<br />' + _('Displaying %{from} to %{to} of %{of}') % {
          :from => '<strong>' + (pager.current.offset + 1).to_s + '</strong>',
          :to => '<strong>' + last.to_s + '</strong>',
          :of => '<strong>'+ pager.item_count.to_s + '</strong>' }

    
    out += "</div>"
    
    out
  end

  def current_user
    @current_user
  end 
 
  # copied from the application controller, but just returns true or false,
  # which is all that is needed for the view templates.
  def check_role( role_symbol )
    return true if @current_user.is_admin?
    if (@project and @current_user )
      # cache the role object once its found
      @_role = @project.user_roles.find_by_user_id(@current_user.id) if ! @_role
      if (@_role.send( role_symbol.to_s ))
        return true
      end
    end
    return false
  end 
end
