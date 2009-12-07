module Kodr
  class App < KParts::MainWindow
    slots :new_document, :open_document, :close_document, :quit, :edit_keys, :toggle_statusbar, :insert_snippet
    
    def initialize(doc=nil)
      super(nil, 0)
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
      set_window_title "Kodr"
      update_status
      show
      # activate first view
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
      actionCollection.addAction( "settings_show_statusbar", m_paShowStatusBar)
      m_paShowStatusBar.setWhatsThis(i18n("Use this command to show or hide the view's statusbar"))
      actionCollection.addAction(KDE::StandardAction::KeyBindings, self, SLOT("edit_keys()")).setWhatsThis(i18n("Configure the application's keyboard shortcut assignments."))
      
      # tools menu
      action = actionCollection.addAction("insert_snippet")
      action.set_text("Insert test snippet")
      connect(action, SIGNAL("triggered()")) do
#         ti = KTextEditor::TemplateInterface.new(active_document)
#         p active_view.kte_view.cursorPosition #(&line,&col);
      # QMap<QString,QString> initVal;
#     if (!sSelection.isEmpty())
#         initVal.insert("selection",sSelection);
#         active_view.kte_view.insertTemplateText(0, 0, "<div class=\"${class}\" id\"${id}\"></div>", {})
      end

      # next tab action
      next_shortcut = KDE::StandardShortcut::tabNext
      next_shortcut.set_alternate(Qt::KeySequence.new("Alt+Right"))
      action = actionCollection.addAction("next_tab")
      action.set_text("Next Tab")
      action.set_icon(KDE::Icon.new("go-next-view"))
      action.set_shortcut(next_shortcut)
      connect(action, SIGNAL("triggered()")) { @view_space.show_next_tab }

      # prev tab action
      prev_shortcut = KDE::StandardShortcut::tabPrev
      prev_shortcut.set_alternate(Qt::KeySequence.new("Alt+Left"))
      action = actionCollection.addAction("prev_tab")
      action.set_text("Previous Tab")
      action.set_icon(KDE::Icon.new("go-previous-view"))
      action.set_shortcut(prev_shortcut)
      connect(action, SIGNAL("triggered()")) { @view_space.show_prev_tab }
      
      # move selected lines up
      action = actionCollection.addAction("move_lines_up")
      action.set_text("Move line(s) up")
      action.set_shortcut(Qt::KeySequence.new("Ctrl+Shift+Up"))
      connect(action, SIGNAL("triggered()")) { puts "moving up!" }

      # move selected lines down
      action = actionCollection.addAction("move_lines_down")
      action.set_text("Move line(s) down")
      action.set_shortcut(Qt::KeySequence.new("Ctrl+Shift+Down"))
      connect(action, SIGNAL("triggered()")) { puts "moving down!" }
      
      # complete word
      action = actionCollection.addAction("complete_word")
      action.set_text("Complete word")
      action.set_shortcut(Qt::KeySequence.new("Esc"))
      connect(action, SIGNAL("triggered()")) { puts "completing!" }
      
      #       action=new KAction(this);
#       action->setText(i18n("&Next Tab"));
#       action->setEnabled(false);
#       connect(action, SIGNAL(triggered()), m_viewContainer, SLOT(showNextView()));
#       actionCollection()->addAction("next_tab", action);
      
#       action=new KAction(this);
#       action->setText(i18n("&Previous Tab"));
#       action->setIcon(KIcon(prevIcon));
#       action->setShortcut(prevShortcut);
#       action->setEnabled(false);
#       connect(action, SIGNAL(triggered()), m_viewContainer, SLOT(showPreviousView()));
#       actionCollection()->addAction("previous_tab", action);
      
    end
    
    def setup_statusbar
    end
    
    def update_status
    end
    
    def active_view
      @view_space.active_view
    end
    
    def active_document
      active_view.kte_view.document
    end
    
    def new_document
      @view_space.set_current_widget(@view_space.open_url(nil))
    end
    
    def open_document
      encoding = active_view.kte_view.document.encoding
      url = active_view.kte_view.document.url.url
      filenames = KDE::FileDialog::getOpenFileNames(KDE::Url.new(""), "", self, i18n("Open File"))
      filenames.each do |filename|
        if @view_space.views.size == 1 && active_view.kte_view.document.url.is_empty && !active_view.kte_view.document.is_modified
          view = @view_space.open_url(filename)
          @view_space.active_view.close
          @view_space.current_widget.focus
        else
          @view_space.set_current_widget(@view_space.open_url(filename))
        end
      end
    end
    
    def close_document
      # ensure there is always at least one view
      if @view_space.views.size == 1
        @view_space.open_url(nil)
      end
      # close active view
      @view_space.active_view.close
      # focus tab which is current tab now
      @view_space.current_widget.focus
    end
    
    def edit_keys
      dlg = KDE::ShortcutsDialog.new(KDE::ShortcutsEditor::AllActions, KDE::ShortcutsEditor::LetterShortcutsAllowed, self)
      dlg.addCollection(actionCollection)
      dlg.addCollection(@view_space.active_view.kte_view.actionCollection)
      dlg.configure
    end
    
  end
end
