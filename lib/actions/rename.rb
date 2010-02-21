module Kodr
    class RenameAction < Action
    description "Rename"
    name "file_rename"
    icon "edit-rename"
    
    def call
      EditorSet.active.editor_for_action.rename # TODO move code here from Editor
    end
  end
end
