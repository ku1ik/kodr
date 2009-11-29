require 'korundum4'
require 'ktexteditor'

class Kodr < KParts::MainWindow
# class Kodr < KDE::MainWindow

  attr_accessor :doc_list, :win_list
  
  def initialize(doc=nil)
    super(nil, 0)

    init_textarea
    init_project_viewer
    
    # resize 250, 150
    # move 300, 300
    # init with more useful size, stolen from konq :)
    unless initial_geometry_set
      resize(Qt::Size.new(700, 480).expanded_to(minimum_size_hint))
    end
  
    # readConfig
    
    win_list << self
  
    set_window_title "Kodr"

    # update_status

    show
    
    # give view focus
    @view.set_focus(Qt::OtherFocusReason)
  end
  
  def init_textarea
    @doc_list = []
    @win_list = []
    
    editor = KTextEditor::EditorChooser::editor
    
    # create document
    doc = editor.create_document(nil)

    # # enable the modified on disk warning dialogs if any
    # if (qobject_cast<KTextEditor::ModificationInterface *>(doc))
      # qobject_cast<KTextEditor::ModificationInterface *>(doc)->setModifiedOnDiskWarning (true);

    doc_list << doc
    @view = doc.create_view(self) #qobject_cast<KTextEditor::View*>(doc->createView (this));
    
    set_XML_file("kodrui.rc")
    create_shell_GUI(true)
    gui_factory.add_client(@view)

    # install a working kate part popup dialog thingy
    @view.set_context_menu(@view.default_context_menu(nil))
    
    set_central_widget(@view)
  end
  
  def init_project_viewer
    @project_viewer = KDE::PushButton.new 'Tree', self
    dock_widget = Qt::DockWidget.new("Dock Widget", self)
    # dock_widget.setAllowedAreas(Qt::LeftDockWidgetArea | Qt::RightDockWidgetArea)
    dock_widget.set_widget(@project_viewer);
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

app = Qt::Application.new ARGV
Kodr.new
app.exec
