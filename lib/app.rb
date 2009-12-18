module Kodr
  class App < KParts::MainWindow
    slots :new_document, :open_document, :close_document, :quit, :edit_keys, :toggle_statusbar, :insert_snippet
    
    def self.instance; @@instance; end
    
    def initialize(doc=nil)
      super(nil, 0)
      @@instance = self
      setup_views
      setup_project_viewer
      setup_actions
      setup_statusbar
      set_XML_file(File.dirname(__FILE__) + "/../kodrui.rc")
      create_shell_GUI(true)
      unless initial_geometry_set
        resize(Qt::Size.new(700, 480).expanded_to(minimum_size_hint))
      end
      set_auto_save_settings
      # readConfig
      update_status
      show
      # activate first view
      @view_space.views.first.activate
      @view_space.views.first.focus
    end
    
    def setup_views
      # vbox = Qt::VBox.new(self)
      # split = Qt::Splitter.new(self)
      # split.setOpaqueResize
      # (1..1).each do |n|
        # @views << Kodr::View.new(split)
      # end
      @view_space = ViewSpace.new(self)
      @view_space.open_url(nil)
      set_central_widget(@view_space)
    end
    
    def setup_project_viewer
      # dir_operator = KDE::KIO::KDirOperator.new(KUrl("/home/kill"), self)
      # dir_operator.set_view(KFile::Simple)
      # dir_operator.view.setSelectionMode(QAbstractItemView::ExtendedSelection)
      # dir_operator.setSizePolicy(QSizePolicy(QSizePolicy::MinimumExpanding, QSizePolicy::MinimumExpanding))
      
#       dir_operator = KDE::PushButton.new 'Tree', self
      tree_view = Qt::TreeView.new(self) #KDE::FileTreeView.new
      dock_widget = Qt::DockWidget.new("Dock Widget", self)
      # dock_widget.setAllowedAreas(Qt::LeftDockWidgetArea | Qt::RightDockWidgetArea)
      dock_widget.set_widget(tree_view)
      add_dock_widget(Qt::LeftDockWidgetArea, dock_widget)
    end

    def setup_actions
      # file menu
      actionCollection.addAction(KDE::StandardAction::Close, "file_close", self, SLOT("close_document()")).setWhatsThis(i18n("Use this command to close the current document"))
      actionCollection.addAction(KDE::StandardAction::New, "file_new", self, SLOT("new_document()")).setWhatsThis(i18n("Use this command to create a new document"))
      actionCollection.addAction(KDE::StandardAction::Open, "file_open", self, SLOT("open_document()")).setWhatsThis(i18n("Use this command to open an existing document for editing"))
      actionCollection.addAction(KDE::StandardAction::Quit, self, SLOT("close()")).setWhatsThis(i18n("Close the current document view"))
      
      # settings menu
      setStandardToolBarMenuEnabled(true)
      m_paShowStatusBar = KDE::StandardAction::showStatusbar(self, SLOT("toggle_statusbar()"), self)
      actionCollection.addAction("settings_show_statusbar", m_paShowStatusBar)
      m_paShowStatusBar.setWhatsThis(i18n("Use this command to show or hide the view's statusbar"))
      actionCollection.addAction(KDE::StandardAction::KeyBindings, self, SLOT("edit_keys()")).setWhatsThis(i18n("Configure the application's keyboard shortcut assignments."))
      
      # tools menu
      action = actionCollection.addAction("insert_snippet")
      action.set_text("Insert test snippet")
      connect(action, SIGNAL("triggered()")) do
        ti = View.active.kte_view.qobject_cast(KTextEditor::TemplateInterface)
#       QMap<QString,QString> initVal;
#     if (!sSelection.isEmpty())
#         initVal.insert("selection",sSelection);
#         <div class=\"${class}\" id=\"${id}\"></div>
        ti.insertTemplateText(View.active.kte_view.cursor_position, "div", ["a", "b"])
      end

      # next tab action
      next_shortcut = KDE::StandardShortcut::tabNext
      next_shortcut.set_alternate(Qt::KeySequence.new("Alt+Right"))
      action = actionCollection.addAction("next_tab")
      action.set_text("Next Tab")
      action.set_icon(KDE::Icon.new("go-next-view"))
      action.set_shortcut(next_shortcut)
      connect(action, SIGNAL("triggered()")) { ViewSpace.active.show_next_tab }

      # prev tab action
      prev_shortcut = KDE::StandardShortcut::tabPrev
      prev_shortcut.set_alternate(Qt::KeySequence.new("Alt+Left"))
      action = actionCollection.addAction("prev_tab")
      action.set_text("Previous Tab")
      action.set_icon(KDE::Icon.new("go-previous-view"))
      action.set_shortcut(prev_shortcut)
      connect(action, SIGNAL("triggered()")) { ViewSpace.active.show_prev_tab }
      
      # Alt+1,2,3,.. tab switching
      1.upto(10) do |n|
        action = action_collection.add_action("tab-#{n}")
        action.set_text("Switch to tab #{n}")
        action.set_shortcut(Qt::KeySequence.new("Alt+#{n % 10}"))
        connect(action, SIGNAL("triggered()")) { ViewSpace.active.set_current_index(n-1) }
      end
      
      Kodr::Command.commands.each { |c| c.register }
    end
    
    def setup_statusbar
    end
    
    def update_status
    end
    
#     def active_document
#       View.active.document
#     end
    
    def new_document
      ViewSpace.active.open_url(nil)
    end
    
    def open_document(url=nil)
      if url
        urls = [url]
      else
        urls = KDE::FileDialog::getOpenUrls(KDE::Url.new(""), "", self, i18n("Open File"))
      end
      urls.each do |url|
        ViewSpace.active.open_url(url)
      end
    end
    
    def close_document
      View.active.close
    end
    
    def edit_keys
      dlg = KDE::ShortcutsDialog.new(KDE::ShortcutsEditor::AllActions, KDE::ShortcutsEditor::LetterShortcutsAllowed, self)
      dlg.add_collection(action_collection)
      dlg.add_collection(View.active.kte_view.action_collection)
      dlg.configure
    end
    
  end
end
