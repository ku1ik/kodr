module Kodr
  module Textmate
    module Indentation
      
      def focusNextPrevChild(next_)
        if next_
          try_indent
        else
          try_unindent
        end
        true
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
      
      def try_unindent
        cursor.begin_edit_block
        if cursor.selected_text
          unindent_selection
        else
          unindent_lines(cursor.line)
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
      
      def unindent_selection
        selection_start, selection_end = [cursor.anchor, cursor.position].sort
        cursor_start, cursor_end = document.cursor_for_position(selection_start), document.cursor_for_position(selection_end)
        first_line, last_line = cursor_start.line, cursor_end.line
        last_line -= 1 if cursor_end.column == 0
        unindent_lines(first_line, last_line)
      end
      
      def insert_whitespace
        d = cursor.column % indentation_width
        width = d > 0 ? indentation_width - d : indentation_width
        insert_text(" " * width)
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
        prev_line = nil
        (line_no-1).downto(0) do |n|
          line = document.line(n)
          if line !~ /^\s*$/
            prev_line = line
            break
          end
        end
        curr_line = document.line(line_no)
        i = 0
        if prev_line
          i += prev_line.indentation
          if prev_line =~ config.bundles.increase_indent_pattern(syntax.scopeName)
            i += 2
          end
        end
        if curr_line =~ config.bundles.decrease_indent_pattern(syntax.scopeName)
          i -= 2
        end
        [0, i].max
      end
      
      def indentation_text
        " " * indentation_width
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
          if current_line =~ config.bundles.decrease_indent_pattern(syntax.scopeName) && $~[0] == document[(cursor.position-$~[0].size)..(cursor.position)]
            set_line_indentation(cursor.line, ideal_line_indentation)
          end
        end
        @internal_change = false
      end
      
    end
  end
end
