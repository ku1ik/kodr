module Kodr

  class EditorSet < KDE::TabWidget
    attr_reader :editors
    attr_accessor :active_editor, :editor_for_context_menu
    @@list = []
    
    def self.active
      @@list.first
    end
    
    def initialize(parent)
      super(parent)
      @@list.<<(self)
      @editors = []
      @active_editor = nil
      set_movable(true)
      setup_tab_close_button
      connect(self, SIGNAL("mouseMiddleClick()")) do
        open_url(nil)
      end
      connect(self, SIGNAL("mouseMiddleClick(QWidget *)")) do |editor|
        editor.close
      end
      connect(self, SIGNAL("currentChanged(int)")) do |index|
        widget(index).update_label if index >= 0
      end
      connect(self, SIGNAL("contextMenu(QWidget*, const QPoint&)")) do |editor, pos|
        self.editor_for_context_menu = editor
        parent_widget.gui_factory.container("tabContextMenu", parent_widget).exec(pos)
        self.editor_for_context_menu = nil
      end
    end
    
    def editor_for_action
      editor_for_context_menu || active_editor
    end
    
    def setup_tab_close_button
      close_button = Qt::ToolButton.new(self)
      close_button.set_icon(KDE::Icon.new("tab-close"))
      close_button.adjust_size
      set_corner_widget(close_button, Qt::BottomRightCorner)
      connect(close_button, SIGNAL("clicked()")) do
        parent_widget.action_collection.action("file_close").trigger
      end
    end
    
    def open_url(url)
      url ||= KDE::Url.new("")
      if !url.is_empty && editor = find_editor_for_url(url)
        set_current_widget(editor)
      else
        if editors.size == 1 && active_editor.view.document.url.is_empty && !active_editor.view.document.is_modified && !url.is_empty
          if editor = create_editor(url)
            active_editor.close
            current_widget.focus
          end
        else
          if editor = create_editor(url)
            set_current_widget(editor)
          end
        end
      end
      editor
    end
    
    def create_document(url)
      doc = KTextEditor::EditorChooser::editor.create_document(nil)
      if url.is_empty
        return doc
      end
      if doc.open_url(url)
        doc
      else
        doc.close_url
        nil
      end
    end
    
    def create_editor(url)
      if doc = create_document(url)
        e = Editor.new(self, doc)
        add_tab(e, e.icon, e.label)
        e.update_tooltip
        @editors << e
        e
      else
        nil
      end
    end
    
    def remove_editor(editor)
      remove_tab(index_of(editor))
      editors.delete(editor)
      # ensure there is always at least one editor
      if editors.size == 0
        open_url(nil)
      end
      # focus new current tab
      current_widget.focus
#       GC.start
    end
    
    def find_editor_for_url(url)
      editors.detect { |e| e.view.document.url == url }
    end
    
    def activate_editor(editor)
      return if active_editor == editor
      main_window = parent_widget
      main_window.set_updates_enabled(false)
      unless active_editor.nil?
        main_window.gui_factory.remove_client(active_editor.view)
      end
      self.active_editor = editor
      main_window.gui_factory.add_client(editor.view)
      main_window.set_updates_enabled(true)
    end
    
    def find_editor_for_view(view)
      editor = @editors.detect { |e| e.view.parent_widget == view.parent_widget }
    end
    
    def show_next_tab
      set_current_index((active_editor.index + 1) % count)
    end
    
    def show_prev_tab
      set_current_index((active_editor.index + count - 1) % count)
    end
  end
  
end
