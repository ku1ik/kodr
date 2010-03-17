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
        @block_states = {}
        @block_state_num = 0
      end
      
      def highlightBlock(line)
        @line = line
        syntax = @editor.syntax or return
        if previousBlockState >= 0
          stack, tag = @block_states[previousBlockState].deep_clone
          @tag = reset_start_positions(tag)
        else
          stack = [[syntax, nil]]
          @tag = { :children => [] }
        end
        @root = @tag
        syntax.send(:parse_line, stack, @line, self)
        data = [stack, remove_closed_tags(@tag.deep_clone)]
        if stack.size == 1
          state = -1
        else
          @block_states[@block_state_num] = data
          state = @block_state_num
          @block_state_num +=1 
        end
        setCurrentBlockState(state)
        highlight_tags([@root])
        
        # old_data = currentBlockUserData
        # new_data = BlockUserData.new(@list)
        # @@data << new_data
        # setCurrentBlockUserData(new_data)
        # @@data.delete(old_data) if @@data.include?(old_data)
      end

      def highlight_tags(tags, scope=[])
        tags.each do |tag|
          tag_scope = tag[:name] ? scope + [tag[:name]] : scope
          unless @cache.key?(tag_scope)
            best = nil
            best_score = 0
            @theme.items.keys.each do |s|
              score = @score_manager.score(s, tag_scope.join(" "))
              if score > best_score
                best_score, best = score, s
              end
            end
            @cache[tag_scope] = best && @theme.items[best]
          end
          (format = @cache[tag_scope]) && set_format(tag[:start], (tag[:end] || @line.size)-tag[:start], format)
          highlight_tags(tag[:children], tag_scope)
        end
      end

      def reset_start_positions(tag)
        if tag[:name]
          tag[:start] = 0
        end
        tag[:children].each do |t|
          reset_start_positions(t)
        end
        tag
      end
      
      def remove_closed_tags(tags)
        tags[:children].delete_if { |t| t[:end] }
        tags[:children].each do |t|
          remove_closed_tags(t)
        end
        tags
      end
  
      def open_tag(name, pos)
        new_tag = { :name => name, :start => pos, :parent => @tag, :children => [] }
        @tag[:children] << new_tag
        @tag = new_tag
      end
  
      def close_tag(name, end_)
        @tag[:end] = end_
        @tag = @tag[:parent]
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
