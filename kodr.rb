require 'korundum4'
require 'ktexteditor'

class Kodr < KParts::MainWindow

  attr_accessor :doc_list, :win_list
  
  def initialize(doc=nil)
    # super

    @doc_list = []
    @win_list = []
    
    editor = KTextEditor::EditorChooser::editor
    
    # set simple mode
    editor.set_simple_mode(true)

    # create document
    doc = editor.create_document(nil)

    # # enable the modified on disk warning dialogs if any
    # if (qobject_cast<KTextEditor::ModificationInterface *>(doc))
      # qobject_cast<KTextEditor::ModificationInterface *>(doc)->setModifiedOnDiskWarning (true);

    doc_list << doc
    view = doc.create_view(self) #qobject_cast<KTextEditor::View*>(doc->createView (this));

    set_central_widget(view)

    # install a working kate part popup dialog thingy
    view.set_context_menu(view.default_context_menu)

    # init with more useful size, stolen from konq :)
    unless initial_geometry_set
      resize(QSize.new(700, 480).expandedTo(minimum_size_hint))
    end
  
    win_list << self
  
    update_status
    show
  
    # give view focus
    view.set_focus(Qt::OtherFocusReason)

    # setWindowTitle "Tooltip"

    # setToolTip "This is Widget"
    
    # init_ui
    
    # resize 250, 150
    # move 300, 300

    # show
  end

  def init_ui
    init_view
    init_menu
  end

  def init_view
    # hbox = Qt::HBoxLayout.new self
    project_tree = KDE::PushButton.new 'Tree', self

    dock_widget = Qt::DockWidget.new("Dock Widget", self)
    # dock_widget.setAllowedAreas(Qt::LeftDockWidgetArea | Qt::RightDockWidgetArea)
    dock_widget.setWidget(project_tree);
    addDockWidget(Qt::LeftDockWidgetArea, dock_widget)
    
    
    textarea = KDE::TextEdit.new self
    setCentralWidget(textarea)
    
    # quit.resize 80, 30
    # quit.move 50, 50
    # connect quit, SIGNAL('clicked()'), $qApp, SLOT('quit()')
    # hbox.addWidget project_tree
    # hbox.addWidget textarea
    
    statusBar.showMessage("Ready")
  end
  
  def init_menu
    quit = Qt::Action.new "&Quit", self
    quit.setShortcut "Ctrl+Q"
    quit.setDisabled true
    
    file_menu = menuBar.addMenu "&File"
    file_menu.addAction quit
    
    connect(quit, SIGNAL("triggered()"), Qt::Application.instance, SLOT("quit()"))
  end

end

app = Qt::Application.new ARGV
Kodr.new
app.exec
