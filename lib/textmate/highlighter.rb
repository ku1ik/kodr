require "textmate/tag"

module Kodr
  module Textmate
    class Highlighter < Qt::SyntaxHighlighter
      @@data = []
      
      def initialize(editor)
        @editor = editor
        super(editor.document)
        @user_data = []
        @score_manager = Textpow::ScoreManager.new
        @cache = {}
        @block_states = {}
        @block_state_num = 0
      end
      
      def highlightBlock(line)
        syntax = @editor.syntax or return
        @line = line
        if previousBlockState >= 0
          stack, @tag = @block_states[previousBlockState].deep_clone
          @tag.reset_start_positions!
        else
          stack = [[syntax, nil]]
          @tag = Tag.new
        end
        @root = @tag
        syntax.send(:parse_line, stack, @line, self)
        data = [stack, @tag.deep_clone]
        data[1].remove_closed_tags!
        if stack.size == 1
          state = -1
        else
          @block_states[@block_state_num] = data
          state = @block_state_num
          @block_state_num +=1
        end
        setCurrentBlockState(state)
        highlight_tags([@root])
        
        # highlight white space at end of line
        if m = /\s+$/.match(@line)
          format = Qt::TextCharFormat.new
          format.set_background(Qt::Brush.new(@editor.theme.ui["lineHighlight"].to_qt))
          set_format(m.begin(0), m.end(0), format)
        end
        
        # old_data = currentBlockUserData
        new_data = BlockUserData.new(@root)
        @user_data << new_data
        setCurrentBlockUserData(new_data)
        # @@data.delete(old_data) if @@data.include?(old_data)
      end

      def highlight_tags(tags, scope=[])
        tags.each do |tag|
          tag_scope = tag.name ? scope + [tag.name] : scope
          unless @cache.key?(tag_scope)
            best = nil
            best_score = 0
            @editor.theme.items.keys.each do |s|
              score = @score_manager.score(s, tag_scope.join(" "))
              if score > best_score
                best_score, best = score, s
              end
            end
            @cache[tag_scope] = best && @editor.theme.items[best]
          end
          (format = @cache[tag_scope]) && set_format(tag.start, (tag.end || @line.size)-tag.start, format)
          highlight_tags(tag.children, tag_scope)
        end
      end

      def open_tag(name, pos)
        new_tag = Tag.new(:name => name, :start => pos, :parent => @tag)
        @tag.children << new_tag
        @tag = new_tag
      end
  
      def close_tag(name, end_)
        @tag.end = end_
        @tag = @tag.parent
      end
      
      def new_line(line); end
      def start_parsing(name); end
      def end_parsing(name); end
  
    end
    
    class BlockUserData < Qt::TextBlockUserData
      attr_reader :tags
      def initialize(tags)
        super()
        @tags = tags
      end
      
      def scope_for_position(pos)
        @tags.scope_for_position(pos).compact.join(" ")
      end
    end
  end
end
