module Kodr

  class ViewSpace < KDE::TabWidget
    attr_reader :views
    attr_accessor :active_view
    @@list = []
    
    def self.active
      @@list.first
    end
    
    def initialize(parent)
      super(parent)
      @@list.<<(self)
      @views = []
      @active_view = nil
      set_movable(true)
      setup_tab_close_button
      connect(self, SIGNAL("mouseMiddleClick()")) do
        open_url(nil)
      end
      connect(self, SIGNAL("mouseMiddleClick(QWidget *)")) do |view|
        view.close
      end
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
      if !url.is_empty && view = find_view_for_url(url)
        set_current_widget(view)
      else
        if views.size == 1 && active_view.kte_view.document.url.is_empty && !active_view.kte_view.document.is_modified && !url.is_empty
          if view = create_view(url)
            active_view.close
            current_widget.focus
          end
        else
          if view = create_view(url)
            set_current_widget(view)
          end
        end
      end
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
    
    def create_view(url)
      if doc = create_document(url)
        v = View.new(self, doc)
        add_tab(v, v.icon, v.label)
        @views << v
        v
      else
        nil
      end
    end
    
    def find_view_for_url(url)
      views.detect { |v| v.kte_view.document.url == url }
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
  
end