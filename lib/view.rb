module Kodr
  
  class ViewSpace < KDE::TabWidget
    attr_reader :views
    attr_accessor :active_view
    
    def initialize(parent)
      super(parent)
      @views = []
      @active_view = nil
      set_movable(true)
      # self.setCloseButtonEnabled(true)
    end
    
    def open_url(url)
      url = KDE::Url.new(url || "")
      v = View.new(self, url)
      add_tab(v, KDE::Icon.new(KDE::MimeType::iconNameForUrl(url)), v.label)
      @views << v
      v
    end
    
    def activate_view(view)
      return if active_view == view
      main_window = parent_widget
      main_window.set_updates_enabled(false)
      unless active_view.nil?
        main_window.gui_factory.remove_client(active_view.kte_view)
      end
      self.active_view = view
      main_window.gui_factory.add_client(view.kte_view)
      main_window.set_updates_enabled(true)
    end
    
    def find_view_for_kte_view(kte_view)
      view = @views.detect { |v| v.kte_view.parent_widget == kte_view.parent_widget }
    end
    
    def show_next_tab
      set_current_index((active_view.index + 1) % count)
    end
    
    def show_prev_tab
      set_current_index((active_view.index + count - 1) % count)
    end
  end
  
  class View < Qt::Widget
    attr_reader :kte_view
    attr_reader :view_space
    
    def initialize(space, url)
      super(nil)
      @view_space = space
      layout = Qt::VBoxLayout.new(self)
      editor = KTextEditor::EditorChooser::editor
      @doc = editor.create_document(nil)
      @doc.open_url(url) unless url.is_empty
      connect(@doc, SIGNAL("documentNameChanged(KTextEditor::Document *)")) do |doc|
        update_label
        view_space.set_tab_icon(index, KDE::Icon.new(KDE::MimeType::iconNameForUrl(doc.url)))
      end
  
      connect(@doc, SIGNAL("modifiedChanged(KTextEditor::Document *)")) do |doc|
        update_label
      end
      
      # , self, SLOT("document_name_changed(KTextEditor::Document *)"));
      # # enable the modified on disk warning dialogs if any
      # if (qobject_cast<KTextEditor::ModificationInterface *>(doc))
      # qobject_cast<KTextEditor::ModificationInterface *>(doc)->setModifiedOnDiskWarning (true);
      
      @kte_view = @doc.create_view(self)
      @kte_view.set_context_menu(@kte_view.default_context_menu(nil))
      connect(@kte_view, SIGNAL("focusIn(KTextEditor::View *)")) { |kte_view| view_space.activate_view(view_space.find_view_for_kte_view(kte_view)) }
      layout.add_widget(@kte_view)
    end
    
    def index
      view_space.index_of(self)
    end
    
    def update_label
      view_space.set_tab_text(index, label)
    end
    
    def label
      name = @doc.url.is_empty ? "Untitled" : @doc.url.file_name
      name + (@doc.is_modified ? " *" : "")
    end
    
    def focus
      @kte_view.set_focus(Qt::OtherFocusReason)
    end
    
    def activate
      view_space.activate_view(self)
    end
    
    def close_document
      @kte_view.document.close_url
    end
    
    def close
      close_document
      view_space.remove_tab(view_space.index_of(self))
      view_space.views.delete(self)
    end
  end
end
