module Kodr
  
  class ViewSpace < KDE::TabWidget
    attr_reader :views
    
    def initialize(parent)
      super(parent)
      @views = []
      
      v = View.new
      @views << v
      add_tab(v, "kodr.rb")

      v = View.new
      @views << v
      add_tab(View.new, "kodrui.rc")
    end
    
  end
  
  class View < Qt::Widget
    
    attr_reader :kte_view
    
    def initialize(parent=nil)
      super(parent)
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

      # layout.add_widget(init_tabs)
      layout.add_widget(@kte_view)
    end
    
  end
end
