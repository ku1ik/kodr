class CloseLastOpenedTag < Kodr::DocumentCommand
  description "Insert slash or close last opened tag"
  name "close_last_opened_tag"
  shortcut "/"
  modes "XML", "HTML", "Ruby/Rails/RHTML"
  
  def call(env)
    response = "/"
    if tag = find_last_opened_tag(env)
      response << "#{tag}>"
    end
    response
  end

  protected
  
  def find_last_opened_tag(env)
    doc = env[:document_text]
    line = env[:line]
    column = env[:column]

    before = /(.*\n){#{line}}.{#{column}}/.match(doc)[0]

    before.gsub!(/<[^>]+\/\s*>/i, '')

    # remove all self-closing tags
    empty_tags = "area|base|basefont|br|col|frame|hr|img|input|isindex|link|meta|param"
    before.gsub!(/<(#{empty_tags})\b[^>]*>/i, '')

    # remove all comments
    before.gsub!(/<!--.*?-->/m, '')

    stack = []
    before.scan(/<\s*(\/)?\s*(\w[\w:-]*)[^>]*>/) do |m|
      if m[0].nil? then
        stack << m[1]
      else
        until stack.empty? do
          close_tag = stack.pop
          break if close_tag == m[1]
        end
      end
    end    
    
    stack.empty? ? nil : stack.pop
  end
end
