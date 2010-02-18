require "plist"
require "pp"

module Kodr
  class TextMateHighlighter < Qt::SyntaxHighlighter
    
    def initialize(editor)
      super(editor.document)
      @syntax = Plist::parse_xml(File.read("#{LIB_DIR}/../syntaxes/xml.plist").gsub("ustring", "string"))
      @theme = editor.theme
    end
    
    def highlightBlock(line)
      matches = {}
#puts "------------------"
      @syntax["patterns"].each do |pattern|
        s = @theme.items[pattern['name']] or next
        regexp = pattern["match"] || pattern["begin"] && pattern["begin"] + ".*?" + pattern["end"]

        if regexp
          line.scan(Regexp.new(regexp)) do
#            puts "found #{pattern['name']}"
            m = $~ 
     #       puts "#{pattern['name']}: #{m[0]}"
            #setFormat(m.begin(0), m.end(0)-m.begin(0), s.to_qt)
            matches[m] = s.to_qt
          end
        end
      end

      last_end = -1
#p matches.keys
      matches.keys.sort_by { |m| m.begin(0) }.each do |m|
#puts "last_end: #{last_end}"
#puts "begin: #{m.begin(0)}"
        next if m.begin(0) < last_end
        s = matches[m]
        setFormat(m.begin(0), m.end(0)-m.begin(0), s)
        last_end = m.end(0)
      end

    end
  end
end
