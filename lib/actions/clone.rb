module Kodr
  class CloneAction < Action
    description "Clone"
    name "file_clone"
    icon "tab-duplicate"
    single_undo_step false
    
    def call
      EditorSet.active.editor_for_action.clone! # TODO: move code here from Editor
    end
  end
end
