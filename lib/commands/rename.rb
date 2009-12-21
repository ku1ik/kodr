class RenameAction < Kodr::Command
  description "Rename"
  name "file_rename"
  icon "edit-rename"
  
  def call(env)
    Kodr::EditorSet.active.editor_for_action.rename
  end
end
