module Kodr
  class CloneAction < Action
    description "Clone"
    name "file_clone"
    icon "tab-duplicate"
    
    def call(env)
      EditorSet.active.editor_for_action.clone!
    end
  end
end
