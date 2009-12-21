class PreviousTabAction < Kodr::Command
  description "Previous Tab"
  name "prev_tab"
  shortcut lambda { KDE::StandardShortcut::tabPrev }
  alternate_shortcut "Alt+Left"
  icon "go-previous-editor"
  
  def call(env)
    Kodr::EditorSet.active.show_prev_tab
  end
end
