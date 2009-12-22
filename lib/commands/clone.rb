class CloneAction < Kodr::Command
  description "Clone"
  name "file_clone"
  icon "tab-duplicate"
  
  def call(env)
    Kodr::EditorSet.active.editor_for_action.clone!
  end
end
