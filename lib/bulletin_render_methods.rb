#
# Functions provided to a bulletin while it is being rendered.
# 
# This is used Only by the ERB rendering method.
#
module BulletinRenderMethods
  
  def base_url
    link_helper.url_for_project_directory(bulletin.project)
  end
  
  def url_for_media(file)
    link_helper.url_for_media(bulletin.project, file)
  end
  
  # Add the base url including domain for the requested file.
  # Also checks to ensure the provided file is not already
  # a complete url, in which case, nothing will be attached.
  def url_for(file)
    url_for_media(file)
  end
  
  # If the provided link does not include the protocol,
  # assume it is a link to an internal page.
  def url_for_link( link )
    link_helper.url_for_link( bulletin.project, :bulletin => bulletin, :link => link )
  end
  
  def url_for_page( page, layout = nil )
    link_helper.url_for_page( bulletin.project, :bulletin => bulletin, :page_name => page, :layout => layout )
  end
  
  def url_for_print
    url_for_bulletin('print')
  end
  
  def url_for_bulletin( layout = nil )
    link_helper.url_for_bulletin(bulletin.project, :bulletin => bulletin, :layout => layout)
  end
  
  def url_for_forward_bulletin
    link_helper.url_for_forward( bulletin.project, :bulletin => bulletin )
  end
  def url_for_forward_page( page )
    link_helper.url_for_forward( bulletin.project, :bulletin => bulletin, :page => page )
  end
  
  def section(name, options = nil)
    section = bulletin.sections.find(:first, :conditions => ['name = ?', name])
    if (! section)
      # try to create a new empty section
      section = Section.new_empty( bulletin, name )
      section.save
    end
    if block_given?
      if @controller
        include_precode
        edit_url = @controller.url_for(:controller => 'sections', :action => 'edit', :id => section.id, :popup => true);
        element_id = "sectionbox"+section.id.to_s
        @_erbout.concat <<-EOF
<div id="editarea" onmouseover="document.getElementById('#{element_id}').style.display = 'block'" 
  onmouseout="document.getElementById('#{element_id}').style.display = 'none'"
  style="padding: 2px; border: 1px red dashed;">
  <div id="#{element_id}" style="padding: 3px; background-color: white; float: left; display: none; position: absolute; z-index: 3; border: 1px solid black;">
      <span style="color: blue;">
      <a href="#{edit_url}" onClick="return popup(this, 'Edit Section')"><img src="/images/icons_big/edit.png" border="0" /></a></span>
  </div>
EOF
      end
      yield section
      if @controller
        @_erbout.concat "</div>"
      end
    else
      return section
    end
  end
  
  def each_section_entry(name, options = nil)
    section = bulletin.sections.find(:first, :conditions => ['name = ?', name])
    if (! section)
      # try to create a new empty section
      section = Section.new_empty(bulletin, name)
      section.save
    end
    if section.entries.empty? 
      # add a new entry
      e = Entry.new_empty(section)
      e.save
      section.entries << e
    end
    section.entries.each do | entry |
      yield section, entry
    end
    
  end

  def each_section(name, options = nil)
    bulletin.sections.find(:all, :conditions => ['name = ?', name]).each do | section |
      yield section
    end
  end
  
  def section_edit_box() 
  
  end
  
  def entry_edit(entry)
    if @controller
      include_precode
      edit_url = @controller.url_for(:controller => 'entries', :action => 'edit', :id => entry.id, :popup => true);  
      up_url = @controller.url_for(:action => 'entry_move_up', :id => entry.id);
      down_url = @controller.url_for(:action => 'entry_move_down', :id => entry.id);
      add_url = @controller.url_for(:controller => 'entries', :action => 'new', :section_id => entry.section_id, :popup => true, :position => entry.position);
      delete_url = @controller.url_for(:action => 'entry_delete', :id => entry.id);
      element_id = 'editbox' + entry.id.to_s

      @_erbout.concat <<-EOF
<div id="editarea" onmouseover="document.getElementById('#{element_id}').style.display = 'block'" 
  onmouseout="document.getElementById('#{element_id}').style.display = 'none'"
  style="padding: 2px; border: 1px red dashed;">
  <div id="#{element_id}" style="padding: 3px; background-color: white; float: left; display: none; position: absolute; z-index: 3; border: 1px solid black; overflow: visable;">
      <a href="#{edit_url}" onClick="return popup(this, 'EditEntry')"><img src="/images/icons_big/edit.png" border="0" /></a>
      <a href="#{add_url}" onClick="return popup(this, 'NewEntry')"><img src="/images/icons_big/add.png" border="0" /></a>
EOF
      if entry.section.entries.count > 1
        @_erbout.concat <<-EOF
      <a href="#{delete_url}" onclick="if (confirm('Are you sure you want to delete this entry?')) { var f = document.createElement('form'); this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href; f.submit(); };return false;">
      <img src="/images/icons_big/remove.png" border="0" /></a>
EOF
        if entry.section.entries.first != entry
          @_erbout.concat <<-EOF
      <a href="#{up_url}"><img src="/images/icons_big/up.png" border="0" /></a>
EOF
        end
        if entry.section.entries.last != entry
          @_erbout.concat <<-EOF
      <a href="#{down_url}"><img src="/images/icons_big/down.png" border="0" /></a>
EOF
        end
      end
      @_erbout.concat "</div>"
    end
    yield
    if @controller
      @_erbout.concat "</div>" 
    end
  end
  
  # Code required to be present at least once, somewhere in the 
  # layout for live-editing
  def include_precode 
    if ! @_included_precode
      @_erbout.concat <<-EOF
<SCRIPT TYPE="text/javascript">
<!--
function popup(mylink, windowname) {
  if (! window.focus) return true;
  var href;
  if (typeof(mylink) == 'string')
    href=mylink;
  else
    href=mylink.href;
  window.open(href, 'test', 'width=750,height=500,scrollbars=yes');
  return false;
}
//-->
</SCRIPT>
EOF
    end
    @_included_precode = true
  end

  protected
    
  def link_helper
    return @_link_helper if @_link_helper
    @_link_helper = BcomposerUrlWriter.new
  end

end
