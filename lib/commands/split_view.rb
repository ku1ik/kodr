class SplitViewVerticallyAction < Kodr::Command
  description "Split view vertically"
  name "split_view_vertically"
  shortcut "Ctrl+3"
  
  def call(env)
    Kodr::App.instance.split_view_vertically
  end
end

class SplitViewHorizontallyAction < Kodr::Command
  description "Split view horizontally"
  name "split_view_horizontally"
  shortcut "Ctrl+2"

  def call(env)
    Kodr::App.instance.split_view_horizontally
  end
end

class UnsplitViewAction < Kodr::Command
  description "Unsplit view"
  name "unsplit_view"
  shortcut "Ctrl+1"
  
  def call(env)
    Kodr::App.instance.unsplit_view
  end
end
