require 'fileutils'

module Kodr
  
  class Editor < Qt::Widget
    attr_reader :kte_view
    attr_reader :editor_set
    
    def self.active
      EditorSet.active.active_editor
    end
    
    def initialize(set, doc)
      super(nil)
      @editor_set = set
      @doc = doc
      connect(@doc, SIGNAL("documentNameChanged(KTextEditor::Document *)")) do |doc|
        update_tab
      end
      connect(@doc, SIGNAL("modifiedChanged(KTextEditor::Document *)")) do |doc|
        update_label
      end
      @doc.qobject_cast(KTextEditor::ModificationInterface).setModifiedOnDiskWarning(true)
      @kte_view = @doc.create_view(self)
      @kte_view.set_context_menu(@kte_view.default_context_menu(nil))
      connect(@kte_view, SIGNAL("focusIn(KTextEditor::View *)")) do |kte_view|
        editor_set.activate_editor(editor_set.find_editor_for_view(kte_view))
      end
      connect(@kte_view, SIGNAL("cursorPositionChanged(KTextEditor::View *, const KTextEditor::Cursor)")) do |kte_view, cursor|
        # notify listeners
      end
      layout = Qt::VBoxLayout.new(self)
      layout.add_widget(@kte_view)
    end
    
    def document
      @kte_view.document
    end
    
    def index
      editor_set.index_of(self)
    end
    
    def update_label
      editor_set.set_tab_text(index, label)
      editor_set.parent_widget.set_window_title(label + " - Kodr")
    end
    
    def update_tooltip
      editor_set.set_tab_tool_tip(index, @doc.url.path_or_url)
    end
    
    def update_tab
      update_label
      update_tooltip
      editor_set.set_tab_icon(index, icon)
    end
    
    def label
      name = @doc.url.is_empty ? "Untitled" : @doc.url.file_name
      name + (@doc.is_modified ? " *" : "")
    end
    
    def icon
      KDE::Icon.new(KDE::MimeType::icon_name_for_url(@doc.url))
    end
    
    def focus
      @kte_view.set_focus(Qt::OtherFocusReason)
    end
    
    def activate
      editor_set.activate_editor(self)
    end
    
    def clone!
      new_editor = EditorSet.active.open_url(nil)
      new_doc = new_editor.kte_view.document
      new_doc.set_mode(document.mode)
      new_doc.set_text(document.text)
      new_editor.kte_view.set_cursor_position(KTextEditor::Cursor.new(0, 0))
    end
    
    def rename
      old_filename = @doc.url.path_or_url
      if @doc.document_save_as && @doc.url.path_or_url != old_filename
        FileUtils.rm old_filename
      end
    end
    
    def close
      if document.close_url
        editor_set.remove_editor(self)
      end
    end
  end
end
