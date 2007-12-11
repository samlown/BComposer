
module BulletinTextHelper

  include ActionView::Helpers::TextHelper

  # convert all <br>s and </p>s into character returns
  # then do some funky stuff with links strip all other html tags.
  def html_to_text( text )
    if text =~ /<\S/  # found a tag!
      text = text.gsub(/[\n\r]/, '')   # remove all newlines
      text.gsub!(/<br\s*\/?>/, "\n")
      text.gsub!(/<\/p>/, "\n")
      
      textize_links_and_strip_tags( text )
    else
      text
    end
  end

  # Remove all links and replace the in the format:
  #   Link name (url)
  # Then stip all other HTML tags.
  # This is based on the RoR strip_tags method
  def textize_links_and_strip_tags( html )
    return html if html.blank?
    if html.index("<")
      text = ""
      link = ""
      tokenizer = HTML::Tokenizer.new(html)

      while token = tokenizer.next
        node = HTML::Node.parse(nil, 0, 0, token, false)
        if node.match :tag => 'a'
          # see if its a link tag
          if ! node.attributes.nil? and node.attributes['href']
            link = node.attributes['href']
          end
        elsif node.class == HTML::Text
          # result is only the content of any Text nodes
          text << node.to_s
          if link != ""
            text << ' ('+link+') '
            link = ""
          end
        end
      end
      
      # strip any comments, and if they have a newline at the end (ie. line with
      # only a comment) strip that too
      text.gsub(/<!--(.*?)-->[\n]?/m, "")
    else
      html # already plain text
    end 
  end
end