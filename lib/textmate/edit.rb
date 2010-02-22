require "textmate/theme"
require "textmate/highlighter"

INC_IND = Regexp.new "^\s*if" #File.read("reg.txt").gsub("&gt;", ">").gsub("&lt;", "")
DEC_IND = %r(^\s*([}\]]\s*$|(end|rescue|ensure|else|elsif|when)\b))

module Kodr
  module Textmate
    class Edit < Qt::PlainTextEdit
      attr_accessor :theme
      slots :text_changed
  
      def initialize(parent, doc)
        super(parent)
        set_document(doc)
        @theme = Theme.new
        @theme.read("#{LIB_DIR}/../themes/Twilight.tmTheme")
        new_palette = palette
        new_palette.set_color(Qt::Palette::Base, @theme.ui["background"].to_qt)
        new_palette.set_color(Qt::Palette::Text, @theme.ui["foreground"].to_qt)
        set_palette(new_palette)
        @highlighter = Textmate::Highlighter.new(self)
        self.connect(self, SIGNAL("textChanged()"), self, SLOT("text_changed()"))
        set_word_wrap_mode(Qt::TextOption::NoWrap)
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
        when Qt::Key_Tab.value
          e.modifiers & Qt::ShiftModifier.value > 0 ? unindent : indent
          return
        when Qt::Key_Return.value
          e.modifiers & Qt::ShiftModifier.value > 0 ? open_newline : insert_newline
          return
        when Qt::Key_Backspace.value
          i = smart_typing_pairs_opening_characters.index(document[cursor.position-1].to_s)
          if i && smart_typing_pairs_closing_characters[i] == document[cursor.position].to_s
            cursor.delete_previous_char
            cursor.delete_char
            return
          end
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
      
      def indent
        insert_text("  ")
      end
      
      def unindent
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
      
      def insert_newline
        insert_text("\n" + current_line[/^\s*/])
        if previous_line =~ INC_IND
          insert_text(indentation_text)
        end
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
        document.findBlockByLineNumber(textCursor.blockNumber-1).text.to_s
      end
      
      def indentation_text
        " " * 2
      end
  
      def text_changed # for auto-unindenting
        log "text_changed"
        prev_indent_size = previous_line[/^\s*/].to_s.size
        curr_indent_size = current_line[/^\s*/].to_s.size
  
        if current_line =~ DEC_IND && (d = prev_indent_size - curr_indent_size) != 2
          p $~
          unindent_width = (previous_line =~ INC_IND ? 0 : 2)
          a = d - unindent_width
          c = cursor
          pos = c.position
          c.move_position(Qt::TextCursor::StartOfLine)
          # set_text_cursor(c)
          if a < 0
            t = [-a, curr_indent_size].min
            t.times { c.deleteChar }
            a = -t
          else
            a.times { c.insertText " " }
          end
          c.set_position(pos + a)
          set_text_cursor(c)
        end
      end
    end
    
    def text_range(line1, col1, line2, col2)
      start = document.cursor_for(line1, col1)
      end_ = document.cursor_for(line2, col2)
      start.move_position(Qt::TextCursor::Right, Qt::TextCursor::KeepAnchor, end_.position - start.position)
      start.selectedText.to_s
    end
    
    def remove_text_range(line1, col1, line2, col2)
      start = document.cursor_for(line1, col1)
      end_ = document.cursor_for(line2, col2)
      start.move_position(Qt::TextCursor::Right, Qt::TextCursor::KeepAnchor, end_.position - start.position)
      start.remove_selected_text
    end
    
  end
end
