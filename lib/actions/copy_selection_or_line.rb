module Kodr
  class CopySelectionOrLineAction < EditorAction
    description "Copy selection or line"
    name "copy_selection_or_line"
    shortcut "Ctrl+C"
    
    def call
      puts "copy action!"
      editor.copy
      # start_line, end_line, range = selected_lines
      # if range.is_valid
      #   Action["edit_copy"].trigger
      # else
      #   view.set_selection(KTextEditor::Range.new(start_line, 0, start_line + 1, 0))
      #   Action["edit_copy"].trigger
      #   view.remove_selection
      # end
    end
  end
end
