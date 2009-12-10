module MoveLines
  def move_lines(delta)
    start_line, end_line, range = *selected_lines
    return if start_line == 0 || end_line + 1 == view.document.lines
    lines = []
    cursor = view.cursor_position
    (end_line - start_line + 1).times do
      lines << view.document.line(start_line)
      view.document.remove_line(start_line)
    end
    view.document.insert_lines(start_line + delta, lines)
    view.set_cursor_position(KTextEditor::Cursor.new(cursor.line + delta, cursor.column))
    if range.is_valid
      view.set_selection(KTextEditor::Range.new(range.start.line + delta, range.start.column, range.end.line + delta, range.end.column))
    end
  end
end

class MoveLinesDownAction < Kodr::Action
  description "Move line(s) down"
  name "move_lines_down"
  shortcut "Alt+Shift+Down"
  
  include MoveLines
  
  def run
    move_lines(1)
  end
end

class MoveLinesUpAction < Kodr::Action
  description "Move line(s) up"
  name "move_lines_up"
  shortcut "Alt+Shift+Up"
  
  include MoveLines
  
  def run
    move_lines(-1)
  end
end
