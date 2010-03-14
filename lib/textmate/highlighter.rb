module Kodr
  module Textmate
    class Highlighter < Qt::SyntaxHighlighter
      @@data = []
      
      def initialize(editor)
        @editor = editor
        super(editor.document)
        @theme = editor.theme
        @data = []
        @score_manager = Textpow::ScoreManager.new
        @cache = {}
        @block_states = []
      end
      
      def highlightBlock(line)
        syntax = @editor.syntax or return
        # @tags = []
        # @list = []
        # @root = @tag = { :children => [] }
        # syntax.parse(line, self)
        # stack = [[syntax, nil]]
        puts "prev: #{previousBlockState}"
        
        if previousBlockState >= 0
          stack, @tag = @block_states[previousBlockState]
        else
          stack = [[syntax, nil]]
          # @tag = []
        end
        @tag ||= { :children => [] }
        @tag[:start] = 0
        
        @root = @tag
        # stack = stack.dup
        # stack = [[syntax, ss || nil]]
        # string.each_line do |line|
        syntax.send(:parse_line, stack, line, self)
        # puts "=" * 80
        # y stack[1]
        # p stack.size
        # raise "aa" unless stack[0] == syntax
        # end
        p @root #@list
        
        @list = []
        @list.sort_by { |e| -e[1] }.sort_by { |e| e[0] }.each do |e|
          unless @cache.key?(e[2])
            best = nil
            best_score = 0
            @theme.items.keys.each do |s|
              score = @score_manager.score(s, e[2])
              if score > best_score
                best_score, best = score, s
              end
            end
            # p best
            @cache[e[2]] = best && @theme.items[best]
          end
          (format = @cache[e[2]]) && set_format(e[0], e[1], format)
        end
        
        # old_data = currentBlockUserData
        # new_data = BlockUserData.new(@list)
        # @@data << new_data
        # setCurrentBlockUserData(new_data)
        # @@data.delete(old_data) if @@data.include?(old_data)
        
        data = [stack, @tag[:name] && @tag]
        state = stack.size == 1 ? -1 : @block_states.index(data)
        if state.nil?
          @block_states << data
          state = @block_states.size - 1
        end
        puts "curr: #{state}"
        puts "-" * 80
        setCurrentBlockState(state)
      end
  
      def open_tag(name, pos)
        # @tags << [name, pos]
        new_tag = { :name => name, :start => pos, :parent => @tag, :children => [] }
        @tag[:children] << new_tag
        @tag = new_tag
        # @list << 
      end
  
      def close_tag(name, end_)
        # tag = @list.reverse.detect { |t| t[:name] == name }
        @tag[:end] = end_
        @tag[:parent][:children].delete(@tag)
        @tag = @tag[:parent]
        # start = tag[]@tags.last[1]
        # name = @tags.map { |e| e[0] }.join(" ")
        # @list << [start, end_-start, name]
        # @tags.pop
        # @list << [start, end_-start, format.to_qt] if format
        # format = @theme.items[name]
        # @list << [start, end_-start, format.to_qt] if format
      end
      
      def new_line(line); end
  
      def start_parsing(name); end
  
      def end_parsing(name); end
  
    end
    
    class BlockUserData < Qt::TextBlockUserData
      attr_reader :data
      def initialize(data)
        super()
        @data = data
      end
    end
  end
end
