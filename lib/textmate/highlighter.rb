require "plist"

module Kodr
  module Textmate
    class Highlighter < Qt::SyntaxHighlighter
      
      def initialize(editor)
        super(editor.document)
        @theme = editor.theme
        @syntaxes = []
        ["Ruby", "Ruby on Rails", "CSS", "JavaScript"].each do |syntax|
          @syntaxes << Textpow::SyntaxNode.new(Plist::parse_xml(File.read("#{LIB_DIR}/../syntaxes/#{syntax}.plist").gsub("ustring", "string")))
        end
        @syntax = @syntaxes.detect { |s| s.scopeName == "source.ruby.rails" }
      end
      
      def highlightBlock(line)
        @stack = []
        @list = []
        @syntax.parse(line, self)
        p line
        @list.sort_by { |e| -e[1] }.sort_by { |e| e[0] }.each do |e|
          set_format(e[0], e[1], e[2])
        end
      end
  
      def open_tag(name, pos)
        @stack << [name, pos]
      end
  
      def close_tag(name, end_)
        name, start = @stack.pop
        format = @theme.items[name]
        @list << [start, end_-start, format.to_qt] if format
      end
  
      def new_line(line); end
  
      def start_parsing(name); end
  
      def end_parsing(name); end
  
    end
  end
end
