require 'fileutils'

module Kodr
  
  class Editor < Qt::Widget
    attr_reader :view
    attr_reader :editor_set
    
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
      @doc.qobject_cast(KTextEditor::ModificationInterface).set_modified_on_disk_warning(true)
      @view = @doc.create_view(self)
      @view.set_context_menu(@view.default_context_menu(nil))
      connect(@view, SIGNAL("focusIn(KTextEditor::View *)")) do |view|
        view.parent_widget.activate
      end
      connect(@view, SIGNAL("cursorPositionChanged(KTextEditor::View *, const KTextEditor::Cursor)")) do |view, cursor|
        # notify listeners
      end
      layout = Qt::VBoxLayout.new(self)
      layout.add_widget(@view)
    end
    
    def document
      @view.document
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
      @view.set_focus(Qt::OtherFocusReason)
    end
    
    def activate
      editor_set.active_editor = self
    end
    
    def clone!
      new_editor = EditorSet.active.open_url(nil)
      new_doc = new_editor.view.document
      new_doc.set_mode(document.mode)
      new_doc.set_text(document.text)
      new_editor.view.set_cursor_position(KTextEditor::Cursor.new(0, 0))
    end
    
    def rename
      old_filename = @doc.url.path_or_url
      if @doc.document_save_as && @doc.url.path_or_url != old_filename
        FileUtils.rm old_filename
      end
    end
    
    def close
      return false unless document.close_url
      editor_set.remove_editor(self)
      true
    end
  end
end
