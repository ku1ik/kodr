module Kodr
  class App < KParts::MainWindow
    slots :new_document, :open_document, :close_document, :quit, :edit_keys, :toggle_statusbar, :insert_snippet
    attr_reader :gui_client
    
    def self.instance; @@instance; end
    
    def initialize(doc=nil)
      super(nil, 0)
      @@instance = self
      setup_editor
      setup_project_viewer
      setup_actions
      setup_statusbar
      set_XML_file("kodrui.rc")
      create_shell_GUI(true)
      unless initial_geometry_set
        resize(Qt::Size.new(700, 480).expanded_to(minimum_size_hint))
      end
      set_auto_save_settings
      # read_config
      update_status
      show
      # activate first editor
      editor = EditorSet.first.editors.first
      editor.activate
      editor.focus
    end
    
    def setup_editor
      @splitter = Qt::Splitter.new(self)
      @splitter.set_opaque_resize
      EditorSet.new(@splitter)
      set_central_widget(@splitter)
    end
    
    def setup_project_viewer
      @tree_view = Qt::TreeView.new(self)
      @model = Kodr::DirModel.new(self, KDE::Url.new(FileUtils.pwd))
      @tree_view.set_model(@model)
      @tree_view.header.hide
      @tree_view.set_sorting_enabled(true)
      @tree_view.sort_by_column(0, Qt::AscendingOrder)
      1.upto(@model.column_count-1) { |n| @tree_view.hide_column(n) }
      connect(@tree_view, SIGNAL("clicked(QModelIndex)")) do |model_index|
        file_item = @model.item_for_index(@model.map_to_source(model_index))
        if file_item.is_file && !file_item.is_dir
          EditorSet.active.open_url(file_item.url).focus
        end
      end
      
      dock_widget = Qt::DockWidget.new("Dock Widget", self)
      # dock_widget.setAllowedAreas(Qt::LeftDockWidgetArea | Qt::RightDockWidgetArea)
      dock_widget.set_widget(@tree_view)
      add_dock_widget(Qt::LeftDockWidgetArea, dock_widget)
    end

    def setup_statusbar
      # line, col
      @line_col_label = Qt::Label.new(status_bar)
      status_bar.add_widget(@line_col_label, 5)

      # line count
      @line_count_label = Qt::Label.new(status_bar)
      status_bar.add_widget(@line_count_label, 30)
      
      # mode icon/switcher
      mode_icon = Qt::Label.new(status_bar)
      mode_icon.set_pixmap(KDE::Icon.new("code-context").pixmap(16))
      mode_icon.set_minimum_size(16, 16)
      status_bar.add_widget(mode_icon, 0)
      @mode_label = Qt::Label.new(status_bar)
      status_bar.add_widget(@mode_label, 1)
      
      # handle click events
      def @line_col_label.mouseReleaseEvent(event)
        EditorSet.active.active_editor.view.action_collection.action("go_goto_line").trigger
      end
      def @line_count_label.mouseReleaseEvent(event)
        EditorSet.active.active_editor.view.action_collection.action("go_goto_line").trigger
      end
      def mode_icon.mouseReleaseEvent(event)
        App.instance.show_mode_menu(event.global_pos)
      end
      def @mode_label.mouseReleaseEvent(event)
        App.instance.show_mode_menu(event.global_pos)
      end
      
      # charset
#       charset_icon = Qt::Label.new(status_bar)
#       charset_icon.set_pixmap(KDE::Icon.new("character-set").pixmap(16))
#       charset_icon.set_minimum_size(16, 16)
#       status_bar.add_widget(charset_icon, 0)
#       @charset_label = Qt::Label.new(status_bar)
#       status_bar.add_widget(@charset_label, 1)
    end
    
    def setup_actions
      # file menu
      action_collection.add_action(KDE::StandardAction::Close, "file_close", self, SLOT("close_document()")).set_whats_this(i18n("Use this command to close the current document"))
      action_collection.add_action(KDE::StandardAction::New, "file_new", self, SLOT("new_document()")).set_whats_this(i18n("Use this command to create a new document"))
      action_collection.add_action(KDE::StandardAction::Open, "file_open", self, SLOT("open_document()")).set_whats_this(i18n("Use this command to open an existing document for editing"))
      action_collection.add_action(KDE::StandardAction::Quit, self, SLOT("close()")).set_whats_this(i18n("Close the current document"))
      
      # settings menu
      set_standard_tool_bar_menu_enabled(true)
      
      action = KDE::StandardAction::show_statusbar(self, SLOT("toggle_statusbar()"), self)
      action_collection.add_action("settings_show_statusbar", action)
      action.set_whats_this(i18n("Use this command to show or hide the editor's statusbar"))
      
      action_collection.add_action(KDE::StandardAction::KeyBindings, self, SLOT("edit_keys()")).set_whats_this(i18n("Configure the application's keyboard shortcut assignments."))
      
      # tools menu
      action = action_collection.add_action("insert_snippet")
      action.set_text("Insert test snippet")
      connect(action, SIGNAL("triggered()")) do
        v = EditorSet.active.active_editor.view
        ti = v.qobject_cast(KTextEditor::TemplateInterface)
#       QMap<QString,QString> initVal;
#     if (!sSelection.isEmpty())
#         initVal.insert("selection",sSelection);
#         <div class=\"${class}\" id=\"${id}\"></div>
        ti.insertTemplateText(v.cursor_position, "<%= ${code} %>", { 'code' => '' })
      end

      # Alt+1,2,3,.. tab switching
      1.upto(10) do |n|
        action = action_collection.add_action("tab-#{n}")
        action.set_text("Switch to tab #{n}")
        action.set_shortcut(Qt::KeySequence.new("Alt+#{n % 10}"))
        connect(action, SIGNAL("triggered()")) { EditorSet.active.set_current_index(n-1) }
      end
      
      Kodr::Action.all.each { |a| a.register }
    end
    
    def gui_client=(view)
      set_updates_enabled(false)
      if @gui_client
        gui_factory.remove_client(@gui_client)
      end
      view.remove_actions("tools_spelling", "tools_spelling_from_cursor", "tools_spelling_selection", 
                          "tools_invoke_code_completion", "wordcompletion")
      gui_factory.add_client(view)
      @gui_client = view
      set_updates_enabled(true)
    end
    
    def update_status
      editor = EditorSet.active && EditorSet.active.active_editor
      if editor
        update_status_cursor_position
        update_status_document_mode
        update_status_line_count
#         update_status_charset
      end
    end
    
    def update_status_document_mode
      mode = EditorSet.active.active_editor.view.document.mode
      mode = "Normal" if mode.blank?
      @mode_label.set_text("#{mode} ")
    end
    
    def update_status_cursor_position
      cursor = EditorSet.active.active_editor.view.cursor_position
      @line_col_label.set_text(" #{cursor.line + 1},#{cursor.column + 1} ")
    end
    
    def update_status_line_count
      n = EditorSet.active.active_editor.view.document.lines
      @line_count_label.set_text("#{n} lines")
    end
    
#     def update_status_charset
#       encoding = EditorSet.active.active_editor.view.document.encoding
#       @charset_label.set_text("#{encoding} ")
#     end
    
    def new_document
      EditorSet.active.open_url(nil)
    end
    
    def open_document(url=nil)
      if url
        urls = [url]
      else
        urls = KDE::FileDialog::getOpenUrls(KDE::Url.new(""), "", self, i18n("Open File"))
      end
      urls.each do |url|
        EditorSet.active.open_url(url)
      end
    end
    
    def close_document
      EditorSet.active.editor_for_action.close
    end
    
    def edit_keys
      dlg = KDE::ShortcutsDialog.new(KDE::ShortcutsEditor::AllActions, KDE::ShortcutsEditor::LetterShortcutsAllowed, self)
      dlg.add_collection(action_collection)
      dlg.add_collection(EditorSet.active.active_editor.view.action_collection)
      dlg.configure
    end
    
    def split_view_vertically
      @splitter.set_orientation(Qt::Horizontal)
      if EditorSet.all.size < 2
        editor_set = EditorSet.new(@splitter)
        editor_set.editors.first.focus
      else
        editor_set = EditorSet.all[1]
      end
      editor_set.set_tab_position(Qt::TabWidget::North)
    end
    
    def split_view_horizontally
      @splitter.set_orientation(Qt::Vertical)
      if EditorSet.all.size < 2
        editor_set = EditorSet.new(@splitter)
        editor_set.editors.first.focus
      else
        editor_set = EditorSet.all[1]
      end
      editor_set.set_tab_position(Qt::TabWidget::South)
    end
    
    def unsplit_view
      return if EditorSet.all.size == 1
      other_editor_set = EditorSet.all.detect { |set| set != EditorSet.active }
      if other_editor_set.close_editors
        EditorSet.all.delete(other_editor_set)
        EditorSet.active.set_tab_position(Qt::TabWidget::North)
        other_editor_set.delete_later
      else
        action = (@splitter.orientation == Qt::Vertical ? SplitViewHorizontallyAction.kde_action : SplitViewVerticallyAction.kde_action)
        action.set_checked(true)
      end
    end
    
    def queryClose
      EditorSet.all.each do |set|
        return false unless set.close_editors
      end
      true
    end
    
    def show_mode_menu(pos)
      EditorSet.active.active_editor.view.action_collection.action("tools_mode").menu.exec(pos)
    end
  end
end
