module Kodr
  class PasteAndAlignAction < Action
    description "Paste and align"
    name "paste_and_align"
    shortcut "Ctrl+V"
    
    def call
      puts "paste action!!"
      editor.paste
      # start_line = view.cursor_position.line
      # Action["edit_paste"].trigger
      # end_line = view.cursor_position.line
      # p start_line
      # p end_line
    end
  end
end
