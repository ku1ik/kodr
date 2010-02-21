module Kodr
  class SplitViewVerticallyAction < Action
    description "Split Vertical"
    name "split_view_vertically"
    shortcut "Ctrl+3"
    alternate_shortcut "Ctrl+Shift+L"
    icon "view-split-left-right"
    group "split_view"
    single_undo_step false
    
    def call
      App.instance.split_view_vertically
    end
  end

  class SplitViewHorizontallyAction < Action
    description "Split Horizontal"
    name "split_view_horizontally"
    shortcut "Ctrl+2"
    alternate_shortcut "Ctrl+Shift+T"
    icon "view-split-top-bottom"
    group "split_view"
    single_undo_step false
    
    def call
      App.instance.split_view_horizontally
    end
  end

  class NoSplitViewAction < Action
    description "No split"
    name "no_split_view"
    shortcut "Ctrl+1"
    alternate_shortcut "Ctrl+Shift+R"
    icon "view-close"
    group "split_view"
    checked true
    single_undo_step false
    
    def call
      App.instance.unsplit_view
    end
  end
end
