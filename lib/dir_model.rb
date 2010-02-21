module Kodr
  class DirModel < Qt::SortFilterProxyModel
    def initialize(parent, url)
      super(parent)
      # @proxy_model = KDE::DirSortFilterProxyModel.new(@model)
      @source_model = KDE::DirModel.new
      @source_model.dir_lister.set_showing_dot_files(true)
      @source_model.dir_lister.set_auto_update(true)
      @source_model.dir_lister.open_url(url)
      set_source_model(@source_model)
    end
    
    def item_for_index(index)
      @source_model.item_for_index(index)
    end
    
    def lessThan(a, b)
      file_a = item_for_index(a)
      file_b = item_for_index(b)
      if file_a.is_dir && file_b.is_dir || !file_a.is_dir && !file_b.is_dir
        super(a, b)
      else
        file_a.is_dir
      end
    end
  end
end
