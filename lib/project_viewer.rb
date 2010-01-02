module Kodr
  class ProjectViewer
    cattr_accessor :instance
    self.instance = nil
    attr_reader :model, :url
    
    def self.get_instance
      self.instance ||= new
    end
    
    def initialize
      log "initializing ProjectViewer"
      @tree_view = Qt::TreeView.new(App.instance)
      @tree_view.header.hide
      @tree_view.set_sorting_enabled(true)
      @tree_view.sort_by_column(0, Qt::AscendingOrder)
      @tree_view.connect(@tree_view, SIGNAL("clicked(QModelIndex)")) do |model_index|
        file_item = model.item_for_index(model.map_to_source(model_index))
        if file_item.is_file && !file_item.is_dir
          EditorSet.active.open_url(file_item.url).focus
        end
      end
      @dock_widget = Qt::DockWidget.new(App.instance)
      @dock_widget.set_object_name("project_viewer_dock_widget")
      @dock_widget.set_widget(@tree_view)
      @dock_widget.connect(@dock_widget, SIGNAL("visibilityChanged(bool)")) do |visible|
        Action["project_view_toggle"].set_checked(visible)
      end
      # dock_widget.setAllowedAreas(Qt::LeftDockWidgetArea | Qt::RightDockWidgetArea)
      App.instance.add_dock_widget(Qt::LeftDockWidgetArea, @dock_widget)
    end
    
    def open_project(url)
      @url = url
      log "opening project #{url.file_name}"
      @dock_widget.set_window_title(url.file_name)
      @model = DirModel.new(App.instance, url)
      @tree_view.set_model(@model)
      1.upto(@model.column_count-1) { |n| @tree_view.hide_column(n) }
      restore
    end
    
    def restore
      unless @dock_widget.toggle_view_action.checked
        @dock_widget.toggle_view_action.trigger
      end
      a = Action["project_view_toggle"]
      a.set_enabled(true)
      a.set_checked(true)
      Action["project_close"].set_enabled(true)
      Action["project_search"].set_enabled(true)
    end
    
    def hide
      if @dock_widget.toggle_view_action.checked
        @dock_widget.toggle_view_action.trigger
      end
      a = Action["project_view_toggle"]
      a.set_enabled(true)
      a.set_checked(false)
    end
    
    def close
      a = Action["project_view_toggle"]
      a.set_enabled(false)
      a.set_checked(false)
      Action["project_close"].set_enabled(false)
      Action["project_search"].set_enabled(false)
      App.instance.remove_dock_widget(@dock_widget)
#       @model.delete_later
#       @tree_view.delete_later
      @dock_widget.delete_later
      self.class.instance = nil
    end
  end
end
