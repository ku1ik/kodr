module Kodr
  class CutSelectionOrLineAction < EditorAction
    description "Cut selection or line"
    name "cut_selection_or_line"
    shortcut "Ctrl+X"
    
    def call
      puts "cut action!!!"
      editor.cut
      # start_line, end_line, range = selected_lines
      # if range.is_valid
      #   Action["edit_cut"].trigger
      # else
      #   view.set_selection(KTextEditor::Range.new(start_line, 0, start_line + 1, 0))
      #   Action["edit_cut"].trigger
      #   view.remove_selection
      # end
    end
  end
end
