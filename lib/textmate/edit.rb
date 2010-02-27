require "textmate/theme"
require "textmate/highlighter"

INC_IND = Regexp.new "^\s*if" #File.read("reg.txt").gsub("&gt;", ">").gsub("&lt;", "")
DEC_IND = %r(^\s*([}\]]\s*$|(end|rescue|ensure|else|elsif|when)\b))

module Kodr
  module Textmate
    class Edit < Qt::PlainTextEdit
      attr_accessor :theme
  
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
        self.connect(doc, SIGNAL("contentsChange(int, int, int)")) { |pos, removed, added| contents_change(pos, removed, added) }
        self.connect(doc, SIGNAL("contentsChanged()")) { contents_changed }
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
      
      def try_indent
        cursor.begin_edit_block
        if cursor.selected_text
          indent_selection
        else
          if current_line.indentation >= cursor.column
            indent_lines(cursor.line)
          else
            insert_whitespace
          end
        end
        cursor.end_edit_block
      end
      
      def indent_lines(first_line, last_line=first_line)
        ideal_adjust = ideal_line_indentation(first_line) - document.line(first_line).indentation
        adjust = ideal_adjust <= 0 ? indentation_width : ideal_adjust # TODO use next_tab_stop position instead of indentation_width
        first_line.upto(last_line) do |line|
          adjust_line_indentation(line, adjust)
        end
        if ideal_adjust > 0 && first_line == last_line
          c = cursor
          c.move_right(ideal_line_indentation(first_line) - cursor.column)
          set_text_cursor(c)
        end
      end
      
      def unindent_lines(first_line, last_line=first_line)
        new_indentation = [document.line(first_line).indentation - indentation_width, 0].max
        adjust = new_indentation - document.line(first_line).indentation
        first_line.upto(last_line) do |line|
          adjust_line_indentation(line, adjust)
        end
      end
      
      def indent_selection
        selection_start, selection_end = [cursor.anchor, cursor.position].sort
        cursor_start, cursor_end = document.cursor_for_position(selection_start), document.cursor_for_position(selection_end)
        first_line, last_line = cursor_start.line, cursor_end.line
        last_line -= 1 if cursor_end.column == 0
        indent_lines(first_line, last_line)
      end
      
      def insert_whitespace
        d = cursor.column % indentation_width
        width = d > 0 ? indentation_width - d : indentation_width
        insert_text(" " * width)
      end
      
      def try_unindent
        cursor.begin_edit_block
        if cursor.selected_text
          unindent_selection
        else
          unindent_lines(cursor.line)
        end
        cursor.end_edit_block
      end
      
      def unindent_selection
        selection_start, selection_end = [cursor.anchor, cursor.position].sort
        cursor_start, cursor_end = document.cursor_for_position(selection_start), document.cursor_for_position(selection_end)
        first_line, last_line = cursor_start.line, cursor_end.line
        last_line -= 1 if cursor_end.column == 0
        unindent_lines(first_line, last_line)
      end
      
      def adjust_line_indentation(line_no, n)
        c = document.cursor_for(line_no, 0)
        if n > 0
          c.insert_text(" " * n)
        else
          c.set_position(c.position - n, Qt::TextCursor::KeepAnchor)
          c.remove_selected_text
        end
      end
      
      def set_line_indentation(line_no, desired)
        adjust_line_indentation(line_no, desired - document.line(line_no).indentation)
      end
      
      def ideal_line_indentation(line_no=cursor.line)
        prev_line = line_no-1 >= 0 ? document.line(line_no-1) : nil
        curr_line = document.line(line_no)
        i = 0
        if prev_line
          i += prev_line.indentation
          if prev_line.increases_indentation?(mode)
            i += 2
          end
        end
        if curr_line.decreases_indentation?(mode)
          i -= 2
        end
        i
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
        document.findBlockByLineNumber(textCursor.blockNumber-1).text.to_s
      end
      
      def indentation_width
        2
      end
      
      def indentation_text
        " " * indentation_width
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
      
      def contents_change(position, chars_removed, chars_added) # for auto-unindenting
        @chars_removed = chars_removed
        @chars_added = chars_added
      end
      
      def contents_changed
        return if @internal_change
        @internal_change = true
        # log "contents_changed: #{position}, #{chars_removed}, #{chars_added}"
        if @chars_removed == 0 && @chars_added == 1
          if current_line =~ DEC_IND && $~[0] == document[(cursor.position-$~[0].size)..(cursor.position)]
            set_line_indentation(cursor.line, ideal_line_indentation)
          end
        end
        @internal_change = false
      end
      
      def insert_text(t)
        insert_plain_text(t)
      end
      
      def focusNextPrevChild(next_)
        if next_
          try_indent
        else
          try_unindent
        end
        true
      end
    end
    
  end
end
