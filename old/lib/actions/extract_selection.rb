module Kodr
  class ExtractSelectionAction < Action
    description "Extract Selection"
    name "extract_selection"
    shortcut "Ctrl+Shift+X"
    single_undo_step false
    
    def call(env)
      Action["edit_cut"].trigger
      original_doc = document
      EditorSet.active.open_url(nil)
      document.set_mode(original_doc.mode)
      Action["edit_paste"].trigger
    end
  end
end
