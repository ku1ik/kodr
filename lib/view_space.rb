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
      @views = []
      @active_view = nil
      set_movable(true)
      setup_tab_close_button
      @@list.<<(self)
    end
    
    def setup_tab_close_button
      close_button = Qt::ToolButton.new(self)
      close_button.set_icon(KDE::Icon.new("tab-close"))
      close_button.adjust_size
      set_corner_widget(close_button, Qt::BottomRightCorner)
      connect(close_button, SIGNAL("clicked()")) { parent_widget.action_collection.action("file_close").trigger }
    end
    
    def open_url(url)
      url ||= KDE::Url.new("")
      if !url.is_empty && view = find_view_for_url(url)
        set_current_widget(view)
      else
        if views.size == 1 && active_view.kte_view.document.url.is_empty && !active_view.kte_view.document.is_modified && !url.is_empty
          view = create_view(url)
          active_view.close
          current_widget.focus
        else
          set_current_widget(create_view(url))
        end
      end
    end
    
    def create_view(url)
      v = View.new(self, url)
      add_tab(v, KDE::Icon.new(KDE::MimeType::iconNameForUrl(url)), v.label)
      @views << v
      v
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