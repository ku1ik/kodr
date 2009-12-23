module Kodr
  class NextTabAction < Action
    description "Next Tab"
    name "next_tab"
    shortcut lambda { KDE::StandardShortcut::tabNext }
    alternate_shortcut "Alt+Right"
    icon "go-next-editor"
    
    def call(env)
      EditorSet.active.show_next_tab
    end
  end
end
