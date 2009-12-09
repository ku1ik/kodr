require File.dirname(__FILE__) + '/move_lines.rb'

class MoveLinesUpAction < Kodr::Action
  description "Move line(s) up"
  name "move_lines_up"
  shortcut "Alt+Shift+Up"

  include MoveLines
  
  def run
    move_lines(-1)
  end
end
