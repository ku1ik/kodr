module Kodr
    class RenameAction < Action
    description "Rename"
    name "file_rename"
    icon "edit-rename"
    
    def call(env)
      EditorSet.active.editor_for_action.rename
    end
  end
end
