require "textmate/theme"
require "textmate/highlighter"
require "textmate/line_numbering"
require "textmate/current_line_highlighting"
require "textmate/indentation"

INC_IND = Regexp.new "^\s*if" #File.read("reg.txt").gsub("&gt;", ">").gsub("&lt;", "")
DEC_IND = %r(^\s*([}\]]\s*$|(end|rescue|ensure|else|elsif|when)\b))

module Kodr
  module Textmate
    class Edit < Qt::PlainTextEdit
      include LineNumbering
      include CurrentLineHighlighting
      include Indentation
      
      attr_accessor :theme
      
      def initialize(parent, doc)
        super(parent)
        set_word_wrap_mode(Qt::TextOption::NoWrap)
        
        # document
        set_document(doc)
        connect(doc, SIGNAL("contentsChange(int, int, int)")) { |pos, removed, added| contents_change(pos, removed, added) }
        connect(doc, SIGNAL("contentsChanged()")) { contents_changed }
        
        # theme
        @theme = Theme.new
        @theme.read("#{LIB_DIR}/../themes/Twilight.tmTheme")
        new_palette = palette
        new_palette.set_color(Qt::Palette::Base, @theme.ui["background"].to_qt)
        new_palette.set_color(Qt::Palette::Text, @theme.ui["foreground"].to_qt)
        new_palette.set_color(Qt::Palette::Highlight, @theme.ui["selection"].to_qt)
        set_palette(new_palette)
        
        # highlighting
        @highlighter = Textmate::Highlighter.new(self)

        # line numbering
        @line_number_area = LineNumberArea.new(self)
        connect(self, SIGNAL("blockCountChanged(int)")) { |n| update_line_number_area_width }
        connect(self, SIGNAL("updateRequest(const QRect &, int)")) { |rect, dy| update_line_number_area(rect, dy) }
        update_line_number_area_width
        
        # current line highlighting
        connect(self, SIGNAL("cursorPositionChanged()")) { highlight_current_line }
        highlight_current_line
      end
      
      def cursor
        text_cursor
      end
  
      def keyPressEvent(e)
        shortcuts = [Qt::KeySequence::Copy, Qt::KeySequence::Cut, Qt::KeySequence::Paste]
        if shortcuts.any? { |s| e.matches(s) }
          KDE::Application.sendEvent(App.instance, e)
          return
        end
        
        case e.key
        when Qt::Key_Return.value
          e.modifiers & Qt::ShiftModifier.value > 0 ? open_newline : insert_newline
          return
        when Qt::Key_Backspace.value && e.modifiers == 0
          i = smart_typing_pairs_opening_characters.index(document[cursor.position-1].to_s)
          if i && smart_typing_pairs_closing_characters[i] == document[cursor.position].to_s
            cursor.delete_previous_char
            cursor.delete_char
            return
          end
          # TODO: unindent
        end
        
        if e.text.size == 1
          # smart pairs: { [ ( " ' `
          if i = smart_typing_pairs_opening_characters.index(e.text)
            insert_text(smart_typing_pairs[i].join)
            c = cursor
            c.move_position(Qt::TextCursor::PreviousCharacter)
            set_text_cursor(c)
            return
          end
          
          # smart pairs: } ] ) " ' `
#          if i = smart_typing_pairs_opening_characters.index(e.text)
#            insert_text(smart_typing_pairs[i].join)
#            c = cursor
#            c.move_position(Qt::TextCursor::PreviousCharacter)
#            set_text_cursor(c)
#            return
#          end

          # slash key
          if e.text == "/" && (document[cursor.position-1].to_s == "<") && (tag = find_last_opened_tag)
            insert_text("/#{tag}>")
            return
          end
        end
        
        super
        # QTextEdit::ensureCursorVisible() # TODO
      end
      
      def find_last_opened_tag
        before = /(.*\n){#{cursor.line}}.{#{cursor.column}}/.match(document.text)[0] # TODO use text_range
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
      
      def insert_newline
        cursor.begin_edit_block
        insert_text("\n")
        set_line_indentation(cursor.line, ideal_line_indentation)
        cursor.end_edit_block
      end
      
      def open_newline
        c = cursor
        c.move_position(Qt::TextCursor::EndOfLine)
        set_text_cursor(c)
        insert_newline
      end
      
      def current_line
        cursor.block.text.to_s
      end
  
      def previous_line
        document.find_block_by_line_number(text_cursor.block_number-1).text.to_s
      end
      
      def indentation_width
        2
      end
      
      def smart_typing_pairs
        [["\"", "\""], ["'", "'"], ["`", "`"], ["(", ")"], ["{", "}"], ["[", "]"]]
      end
      
      def smart_typing_pairs_opening_characters
        smart_typing_pairs.map { |p| p[0] }
      end
      
      def smart_typing_pairs_closing_characters
        smart_typing_pairs.map { |p| p[1] }
      end
      
      def insert_text(t)
        insert_plain_text(t)
      end
      
    end
    
  end
end
