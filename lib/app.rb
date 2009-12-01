module Kodr
  class App < KParts::MainWindow
  
    # attr_accessor :docs, :views
    attr_accessor :gui_merged_view
    
    def initialize(doc=nil)
      super(nil, 0)
  
      # @docs = []
      # @views = []
      
      init_project_viewer
      init_views
      
      set_XML_file("kodrui.rc")
      create_shell_GUI(true)
      # gui_factory.add_client(@views.first.kview)

      # central = Qt::Widget.new(self)
      # layout = Qt::VBoxLayout.new(central)
  
      # tab_bar = KDE::TabBar.new(self)
      # tab_bar.expanding = false
      # tab_bar.add_tab("kodr.rb")
      # tab_bar.add_tab("kodrui.rc")
      
      # layout.add_widget(tab_bar)
      # layout.add_widget(@view)
      
      # set_central_widget(central)
  
      # resize 250, 150
      # move 300, 300
      # init with more useful size, stolen from konq :)
      unless initial_geometry_set
        resize(Qt::Size.new(700, 480).expanded_to(minimum_size_hint))
      end
    
      # readConfig
      
      # win_list << self
    
      set_window_title "Kodr"
  
      # update_status
  
      show
      
      # give view focus
      @view_space.views.first.kte_view.set_focus(Qt::OtherFocusReason)
    end
    
    def init_views
      # vbox = Qt::VBox.new(self)
      # split = Qt::Splitter.new(self)
      # split.setOpaqueResize

      # (1..1).each do |n|
        # @views << Kodr::View.new(split)
      # end
      @view_space = ViewSpace.new(self)

      set_central_widget(@view_space)
    end
    
    def init_project_viewer
      # dir_operator = KDE::KIO::KDirOperator.new(KUrl("/home/kill"), self)
      # dir_operator.set_view(KFile::Simple)
      # dir_operator.view.setSelectionMode(QAbstractItemView::ExtendedSelection)
      # dir_operator.setSizePolicy(QSizePolicy(QSizePolicy::MinimumExpanding, QSizePolicy::MinimumExpanding))
      
      dir_operator = KDE::PushButton.new 'Tree', self
      
      dock_widget = Qt::DockWidget.new("Dock Widget", self)
      # dock_widget.setAllowedAreas(Qt::LeftDockWidgetArea | Qt::RightDockWidgetArea)
      dock_widget.set_widget(dir_operator)
      add_dock_widget(Qt::LeftDockWidgetArea, dock_widget)
    end
  
    # def init_ui
    #   init_menu
    # end
  
    # def init_menu
    #   quit = Qt::Action.new "&Quit", self
    #   quit.setShortcut "Ctrl+Q"
    #   quit.setDisabled true
      
    #   file_menu = menuBar.addMenu "&File"
    #   file_menu.addAction quit
      
    #   connect(quit, SIGNAL("triggered()"), Qt::Application.instance, SLOT("quit()"))
    # end
  
  end
end
