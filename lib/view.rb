module Kodr
  
  class ViewSpace < KDE::TabWidget
    attr_reader :views
    attr_accessor :active_view
    
    def initialize(parent)
      super(parent)
      @views = []
      @active_view = nil
    end
    
    def open_url(url)
      url = KDE::Url.new(url)
      v = create_view(url)
      @views << v
      add_tab(v, url.file_name)
    end
    
    def create_view(url)
      View.new(self, url)
    end
    
    def activate_view(view)
      # puts "activating view: #{view}"
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
    
  end
  
  class View < Qt::Widget
    
    attr_reader :kte_view
    attr_reader :view_space
    
    def initialize(space, url)
      super(nil)
      @view_space = space
      @url = url
      
      layout = Qt::VBoxLayout.new(self)
      editor = KTextEditor::EditorChooser::editor
      doc = editor.create_document(nil)
      doc.open_url(@url)
      # # enable the modified on disk warning dialogs if any
      # if (qobject_cast<KTextEditor::ModificationInterface *>(doc))
        # qobject_cast<KTextEditor::ModificationInterface *>(doc)->setModifiedOnDiskWarning (true);
      @kte_view = doc.create_view(self)
      @kte_view.set_context_menu(@kte_view.default_context_menu(nil))
      connect(@kte_view, SIGNAL("focusIn(KTextEditor::View *)")) { |kte_view| view_space.activate_view(view_space.find_view_for_kte_view(kte_view)) }
      layout.add_widget(@kte_view)
    end
    
    def focus
      @kte_view.set_focus(Qt::OtherFocusReason)
    end
    
    def activate
      view_space.activate_view(self)
    end
    
    def close_document
      puts "closing doc #{@kte_view.document}"
      @kte_view.document.close_url
    end
    
    def to_s
      @url
    end
    
  end
end
