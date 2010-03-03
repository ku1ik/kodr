module Kodr
  module Textmate
    class Highlighter < Qt::SyntaxHighlighter
      def initialize(editor)
        @editor = editor
        super(editor.document)
        @theme = editor.theme
      end
      
      def highlightBlock(line)
        syntax = @editor.syntax or return
        @stack = []
        @list = []
        syntax.parse(line, self)
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
