module Kodr
  class SearchInDirectoryDialog < KDE::Dialog
    attr_reader :search_box, :search_results
    
    def initialize(parent)
      super(parent)
      set_caption(caption)
      resize(Qt::Size.new(600, 500).expanded_to(minimum_size_hint))
      set_buttons(KDE::Dialog::User1 | KDE::Dialog::Close)
      set_button_text(KDE::Dialog::User1, "Search")
      set_button_icon(KDE::Dialog::User1, KDE::Icon.new("edit-find"))
      set_default_button(KDE::Dialog::User1)
      connect(self, SIGNAL("user1Clicked()")) do
        if search_results.has_focus && search_results.current_item
          open_item(search_results.current_item)
          close
        else
          do_search(search_box.text)
        end
      end
      build_form
      @search_box.set_focus
    end
    
    def caption
      "Search In Directory"
    end
    
    def build_form
      @main_layout = Qt::VBoxLayout.new(main_widget)
      build_top_section
      build_dir_chooser
      build_search_results
    end
    
    def build_top_section
      @top_layout = Qt::FormLayout.new
      @search_box = KDE::LineEdit.new
      @top_layout.add_row("Pattern:", @search_box)
      connect(@search_box, SIGNAL("returnPressed(const QString)")) do |s|
        do_search(s)
      end
      @main_layout.add_layout(@top_layout, 0)
    end
    
    def build_dir_chooser
      @top_layout.add_row("Folder:", Qt::LineEdit.new)
    end
    
    def build_search_results
      @search_results = Qt::TreeWidget.new
      @search_results.set_items_expandable(false)
      @search_results.set_root_is_decorated(false)
      @search_results.set_column_count(2)
      @search_results.set_header_labels(["File/Line", "Match"])
      connect(@search_results, SIGNAL("itemDoubleClicked(QTreeWidgetItem *, int)")) do |item, column|
        open_item(item)
      end
      @main_layout.add_widget(@search_results)
    end
    
    def open_item(item)
      filename, line = item.text(0).split(':')
      url = KDE::Url.new(directory + "/" + filename)
      EditorSet.active.open_url(url, line.to_i)
    end
    
    def enable_search(bool)
      @search_box.set_enabled(bool)
      button(KDE::Dialog::User1).set_enabled(bool)
    end
    
    def directory
      ProjectViewer.get_instance.url.path
    end
    
    def do_search(s)
      search_results.clear
      if s.blank?
        return
      end
      enable_search(false)
      ack = Ack.new("-QaH --nocolor", s, directory)
      ack.on_success { on_finish }
      ack.on_error   { on_finish }
      ack.on_ready_read do
        while !(line = ack.read_line).is_empty
          if m = line.to_s.match(/(.+):(\d+):(.+)/)
            item = Qt::TreeWidgetItem.new
            item.set_text(0, "#{m[1]}:#{m[2]}")
            item.set_text(1, m[3])
            search_results.add_top_level_item(item)
            search_results.set_current_item(item) unless search_results.current_item
          end
        end
      end
      ack.start
    end
    
    def on_finish
      enable_search(true)
      if search_results.count == 0
        search_box.set_focus
      end
      search_results.resize_column_to_contents(0)
      # TODO: results count
    end
  end
end
