require File.dirname(__FILE__) + '/move_lines.rb'

class MoveLinesDownAction < Kodr::Action
  description "Move line(s) down"
  name "move_lines_down"
  shortcut "Alt+Shift+Down"

  include MoveLines
  
  def run
    move_lines(1)
  end
end
