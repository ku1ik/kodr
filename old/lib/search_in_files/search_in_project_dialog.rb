module Kodr
  class SearchInProjectDialog < SearchInDirectoryDialog
    def caption
      "Search In Project"
    end
    
    def build_dir_chooser; end
  end
end
