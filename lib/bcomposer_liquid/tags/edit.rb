#
# = Bcomposer Liquid Edit Block
# 
# Takes the provided name and provides an editable area around it. This is
# required as often the body of an entry is inside structural elements
# such as <td> or <li> which can not show data outside the area.
# 
# Of course, if you do not want to support "live-edit" then bcomposer
# will function perfectly well without defining edit blocks.
# 
# The edit area option currently can be either an entry, or section.
# 
# For example:
# 
#  {% section 'sample' %}
#    <div id="section">
#      {% edit section %}
#        <h1>{{ section.title }}</h1>
#        <h2>{{ section.subtitle }}</h2>
#      {% endedit %}
#    </div>
#  {% endsection %}
# 
# The dynamic edit block will only provide editing options if a controller
# is provided in the context registers, otherwise it is impossible to 
# determine the correct links.
# 
class BcomposerLiquid::Tags::Edit < Liquid::Block

  Syntax = /(#{Liquid::VariableSignature}+)/

  def initialize( tag_name, markup, tokens )

    if markup =~ Syntax
      @type = $1
      if ! ['entry', 'section'].include? @type
        raise "Invalid edit tag! edit does not handle type '#{@type}'"
      end
    else 
      raise "Invalid edit tag"
    end
    
    super
  end

  def render( context )
    function = (@type == 'section' ? 'edit_section' : 'edit_entry')
    item = context.registers[@type.to_sym]
    raise "Edit: not included in #{@type} area, or no #{@type} available!" if (! item)

    res = []
    if context.registers[:controller]
      if ! context.registers[:include_precode]
        res << include_precode
        context.registers[:include_precode] = true
      end
    end
    
    res += self.send(function, context.registers[:controller], item) do | result |
      # add to the results
      result << render_all(@nodelist, context)
    end
    return res
  end

  protected
  
  # Provide the text body of a section
  def edit_section( controller, section )
    result = []
    if controller
      text = ""
      edit_url = controller.url_for(:controller => 'sections', :action => 'edit', :id => section.id, :popup => true)
      element_id = "sectionbox"+section.id.to_s
      text.concat <<-EOF
<div id="editarea" onmouseover="document.getElementById('#{element_id}').style.display = 'block'" 
  onmouseout="document.getElementById('#{element_id}').style.display = 'none'"
  style="padding: 2px; border: 1px red dashed;">
  <div id="#{element_id}" style="padding: 3px; background-color: white; float: left; display: none; position: absolute; z-index: 3; border: 1px solid black;">
      <span style="color: blue;">
      <a href="#{edit_url}" onClick="return popup(this, 'Edit Section')"><img src="/images/icons_big/edit.png" border="0" /></a></span>
  </div>
EOF
      result << text 
    end
    
    yield result
    
    if controller
      result << "</div>"
    end
    result
  end
  
  def edit_entry( controller, entry )
    result = []
    if controller
      text = ""
      edit_url = controller.url_for(:controller => 'entries', :action => 'edit', :id => entry.id, :popup => true);  
      up_url = controller.url_for(:action => 'entry_move_up', :id => entry.id);
      down_url = controller.url_for(:action => 'entry_move_down', :id => entry.id);
      add_url = controller.url_for(:controller => 'entries', :action => 'new', :section_id => entry.section_id, :popup => true, :position => entry.position);
      delete_url = controller.url_for(:action => 'entry_delete', :id => entry.id);
      element_id = 'editbox' + entry.id.to_s
  
      text.concat <<-EOF
<div id="editarea" onmouseover="document.getElementById('#{element_id}').style.display = 'block'" 
  onmouseout="document.getElementById('#{element_id}').style.display = 'none'"
  style="padding: 2px; border: 1px red dashed;">
  <div id="#{element_id}" style="padding: 3px; background-color: white; float: left; display: none; position: absolute; z-index: 3; border: 1px solid black; overflow: visable;">
      <a href="#{edit_url}" onClick="return popup(this, 'EditEntry')"><img src="/images/icons_big/edit.png" border="0" /></a>
      <a href="#{add_url}" onClick="return popup(this, 'NewEntry')"><img src="/images/icons_big/add.png" border="0" /></a>
EOF
      if entry.section.entries.count > 1
        text.concat <<-EOF
      <a href="#{delete_url}" onclick="if (confirm('Are you sure you want to delete this entry?')) { var f = document.createElement('form'); this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href; f.submit(); };return false;">
      <img src="/images/icons_big/remove.png" border="0" /></a>
EOF
        if entry.section.entries.first != entry
          text.concat <<-EOF
      <a href="#{up_url}"><img src="/images/icons_big/up.png" border="0" /></a>
EOF
        end
        if entry.section.entries.last != entry
          text.concat <<-EOF
      <a href="#{down_url}"><img src="/images/icons_big/down.png" border="0" /></a>
EOF
        end
      end
      text.concat "</div>"
      result << text
    end # if controller
    
    yield result
    
    if controller
      result << "</div>"
    end
    result
  end
  
    # Code required to be present at least once, somewhere in the 
  # layout for live-editing
  def include_precode
    text = ""
    text.concat <<-EOF
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
    text
  end

end

Liquid::Template.register_tag('edit', BcomposerLiquid::Tags::Edit)