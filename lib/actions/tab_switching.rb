module Kodr
  class PreviousTabAction < Action
    description "Previous Tab"
    name "prev_tab"
    shortcut lambda { KDE::StandardShortcut::tabPrev } #FIXME
    alternate_shortcut "Alt+Left"
    icon "go-previous-editor"
    single_undo_step false
    
    def call
      EditorSet.active.show_prev_tab
    end
  end
  
  class NextTabAction < Action
    description "Next Tab"
    name "next_tab"
    shortcut lambda { KDE::StandardShortcut::tabNext } #FIXME
    alternate_shortcut "Alt+Right"
    icon "go-next-editor"
    single_undo_step false
    
    def call
      EditorSet.active.show_next_tab
    end
  end
end
