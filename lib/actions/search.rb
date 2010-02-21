module Kodr
  class SearchInProjectAction < Action
    description "Search..."
    name "project_search"
    shortcut "Ctrl+Alt+F"
    icon "edit-find"
    enabled false
    
    def call
      dlg = SearchInProjectDialog.new(App.instance)
      dlg.show
    end
  end
end
