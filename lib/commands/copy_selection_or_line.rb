class CopySelectionOrLineAction < Kodr::Command
  description "Copy selection or line"
  name "copy_selection_or_line"
  
  def call(env)
    start_line, end_line, range = selected_lines
    unless range.is_valid
      view.set_selection(KTextEditor::Range.new(start_line, 0, start_line + 1, 0))
      find_action("edit_copy").trigger
      view.remove_selection
    else
      find_action("edit_copy").trigger
    end
  end
end
