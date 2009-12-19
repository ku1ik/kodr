require 'fileutils'

module Kodr
  
  class View < Qt::Widget
    attr_reader :kte_view
    attr_reader :view_space
    
    def self.active
      ViewSpace.active.active_view
    end
    
    def initialize(space, doc)
      super(nil)
      @view_space = space
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
        view_space.activate_view(view_space.find_view_for_kte_view(kte_view))
      end
      connect(@kte_view, SIGNAL("cursorPositionChanged(KTextEditor::View *, const KTextEditor::Cursor)")) do |kte_view, cursor|
        # notify listeners
      end
      layout = Qt::VBoxLayout.new(self)
      layout.add_widget(@kte_view)
    end
    
    def index
      view_space.index_of(self)
    end
    
    def update_label
      view_space.set_tab_text(index, label)
      view_space.parent_widget.set_window_title(label + " - Kodr")
    end
    
    def update_tooltip
      view_space.set_tab_tool_tip(index, @doc.url.path_or_url)
    end
    
    def update_tab
      update_label
      update_tooltip
      view_space.set_tab_icon(index, icon)
    end
    
    def label
      name = @doc.url.is_empty ? "Untitled" : @doc.url.file_name
      name + (@doc.is_modified ? " *" : "")
    end
    
    def icon
      KDE::Icon.new(KDE::MimeType::iconNameForUrl(@doc.url))
    end
    
    def focus
      @kte_view.set_focus(Qt::OtherFocusReason)
    end
    
    def activate
      view_space.activate_view(self)
    end
    
    def clone!
      doc = kte_view.document
      new_view = ViewSpace.active.open_url(nil)
      new_doc = new_view.kte_view.document
      new_doc.set_mode(doc.mode)
      new_doc.set_text(doc.text)
      new_view.kte_view.set_cursor_position(KTextEditor::Cursor.new(0, 0))
    end
    
    def rename
      old_filename = @doc.url.path_or_url
      if @doc.document_save_as && @doc.url.path_or_url != old_filename
        FileUtils.rm old_filename
      end
    end
    
    def close
      if @kte_view.document.close_url
        view_space.remove_view(self)
      end
    end
  end
end
