module Kodr
  class App < Qt::MainWindow
    def initialize
      super
      @editor = TextMateEdit.new
      set_central_widget(@editor)
      @editor.set_plain_text(File.read("lib/text_mate_edit.rb"))
      
      @file_menu = menu_bar.add_menu("&File");
      # @tlb = add_tool_bar("File")
      
      status_bar
      
#      dockWidget = Qt::DockWidget.new("Dock Widget", self)
      # @model = Qt::FileSystemModel.new
#      @model = Qt::DirModel.new
      # @model.set_root_path(File.expand_path("~/code/kodr"))
#      @project_viewer = Qt::TreeView.new
#      @project_viewer.set_model(@model)
#      dockWidget.setWidget(@project_viewer)
#      addDockWidget(Qt::DockWidgetArea::LeftDockWidgetArea, dockWidget)
      resize 800, 600
    end
  end
end
