require "plist"
require "pp"

module Kodr
  class TextMateHighlighter < Qt::SyntaxHighlighter
    # SCHEME = {
      # :keyword => Qt::TextCharFormat.new.tap { |f| f.set_font_weight(75); f.set_foreground(Qt::Brush.new(Qt::Color.new(80, 10, 120))) },
      # :string => Qt::TextCharFormat.new.tap { |f| f.set_foreground(Qt::Brush.new(Qt::Color.new(0, 200, 20))) },
    # }
    
    def initialize(document)
      super
      @syntax = Plist::parse_xml(File.read("#{LIB_DIR}/../syntaxes/xml.plist").gsub("ustring", "string"))
      @theme = Plist::parse_xml(File.read("#{LIB_DIR}/../themes/Sunburst.tmTheme").gsub("ustring", "string"))["settings"]
      @theme.delete_at(0)
      #[0]["settings"]
      p @theme
    end
    
    def highlightBlock(line)
      puts "--------------------"
      @syntax["patterns"].each do |pattern|
        if regexp = pattern["match"]
          if m = Regexp.new(regexp).match(line)
            puts "#{pattern['name']}: #{m[0]}"
          end
        end
      end
      # setFormat(i, token.to_s.size, fmt)
      # setFormat(i, 1, Qt::Color.new(i, i * 3, i * 9))
    end
  end
end
