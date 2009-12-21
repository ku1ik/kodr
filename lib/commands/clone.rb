class CloneAction < Kodr::Command
  description "Clone"
  name "file_clone"
  icon "edit-copy"
  
  def call(env)
    Kodr::EditorSet.active.editor_for_action.clone!
  end
end
