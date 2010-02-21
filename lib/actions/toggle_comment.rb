module Kodr
  class ToggleCommentAction < EditorAction
    description "Toggle comment"
    name "toggle_comment"
    shortcut "Ctrl+/"

    def call
      start_line, end_line, range = *selected_lines
      orig_text = selected_lines_text
      Action["tools_uncomment"].trigger
      new_text = selected_lines_text
      if orig_text == new_text
        Action["tools_comment"].trigger
      end
    end
    
    protected
    
    def selected_lines_text
      start_line, end_line, range = *selected_lines
      text = ""
      start_line.upto(end_line) do |n|
        text << view.document.line(n).to_s
      end
      text
    end
  end
end
