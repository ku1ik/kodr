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
      v = create_view(url)
      @views << v
      add_tab(v, url)
    end
    
    def create_view(url)
      v = View.new(self, url)
      v
    end
    
    def activate_view(view)
      puts "activating view: #{view}"
      return if active_view == view
      main_window = parent_widget
      puts "yeah"
      main_window.set_updates_enabled(false)
      unless active_view.nil?
        main_window.gui_factory.remove_client(active_view.kte_view)
      end
      active_view = view
      main_window.gui_factory.add_client(view.kte_view)
      main_window.set_updates_enabled(true)
    end
    
    def find_view_for_kte_view(kte_view)
      puts "find_view_for_kte_view"
      p kte_view
      p @views.map { |v| v.kte_view }
      view = @views.detect { |v| v.kte_view.eql? kte_view }
      p view
      view
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
      # create document
      doc = editor.create_document(nil)
  
      # # enable the modified on disk warning dialogs if any
      # if (qobject_cast<KTextEditor::ModificationInterface *>(doc))
        # qobject_cast<KTextEditor::ModificationInterface *>(doc)->setModifiedOnDiskWarning (true);
  
      # doc_list << doc
      @kte_view = doc.create_view(self) #qobject_cast<KTextEditor::View*>(doc->createView (this));
      
      # install a working kate part popup dialog thingy
      @kte_view.set_context_menu(@kte_view.default_context_menu(nil))

      # connect(view, SIGNAL(focusIn(KTextEditor::View *)), this, SLOT(activateSpace(KTextEditor::View *)));
      connect(@kte_view, SIGNAL("focusIn(KTextEditor::View *)")) { |kte_view| view_space.activate_view(view_space.find_view_for_kte_view(kte_view)) }

      # layout.add_widget(init_tabs)
      layout.add_widget(@kte_view)
    end
    
    def focus
      @kte_view.set_focus(Qt::OtherFocusReason)
    end
    
    def activate
      view_space.activate_view(self)
    end
    
    def to_s
      @url
    end
    
  end
end
