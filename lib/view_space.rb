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
  
end