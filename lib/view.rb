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
        update_label
        view_space.set_tab_icon(index, icon)
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
      update_label
    end
    
    def index
      view_space.index_of(self)
    end
    
    def update_label
      view_space.set_tab_text(index, label)
      view_space.parent_widget.set_window_title(label + " - Kodr")
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
    
    def close
      if @kte_view.document.close_url
        view_space.remove_tab(view_space.index_of(self))
        view_space.views.delete(self)
        # ensure there is always at least one view
        if view_space.views.size == 0
          view_space.open_url(nil)
        end
        # focus new current tab
        view_space.current_widget.focus
      end
    end
  end
end
