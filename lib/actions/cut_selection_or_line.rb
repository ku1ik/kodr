module Kodr
  class CutSelectionOrLineAction < Action
    description "Cut selection or line"
    name "cut_selection_or_line"
    
    def call(env)
      start_line, end_line, range = selected_lines
      if range.is_valid
        find_action("edit_cut").trigger
      else
        view.set_selection(KTextEditor::Range.new(start_line, 0, start_line + 1, 0))
        find_action("edit_cut").trigger
        view.remove_selection
      end
    end
  end
end
