require 'fileutils'
require "textmate/edit"
require "text_document"

module Kodr
  class Editor < Textmate::Edit
    attr_accessor :cursor_position_changed_at
    attr_reader :editor_set
    
    def initialize(set, doc)
      super(set, doc)
      @editor_set = set
      # set_mode
      # @view.set_context_menu(@view.default_context_menu(nil))
      # connect(@doc, SIGNAL("documentNameChanged(KTextEditor::Document *)")) do |doc|
      #   update_tab
      # end
      connect(doc, SIGNAL("modificationChanged(bool)")) do |modified|
        Kodr::Action["file_save"].set_enabled(modified)
        update_label
      end
      # connect(@doc, SIGNAL("modeChanged(KTextEditor::Document *)")) do |doc|
      #   App.instance.update_status_document_mode
      # end
      connect(self, SIGNAL("textChanged()")) do
        Kodr::App.instance.update_status_line_count
      end
      connect(self, SIGNAL("cursorPositionChanged()")) do
        Kodr::App.instance.update_status_cursor_position
      end
    end
    
    def focusInEvent(event)
      super
      activate
    end
    
    def url
      document.url
    end
    
    def mode
      ""
    end
    
    def set_mode(new_mode)
    end
    
    def index
      editor_set.index_of(self)
    end
    
    def update_label
      editor_set.set_tab_text(index, label)
      editor_set.parent_widget.parent_widget.set_window_title(label + " - Kodr")
    end
    
    def update_tooltip
      editor_set.set_tab_tool_tip(index, document.url.path_or_url)
    end
    
    def update_tab
      update_label
      update_tooltip
      editor_set.set_tab_icon(index, icon)
    end
    
    def label
      name = document.url.is_empty ? "Untitled" : document.url.file_name
      name + (document.is_modified ? " *" : "")
    end
    
    def icon
      KDE::Icon.new(KDE::MimeType::icon_name_for_url(document.url))
    end
    
    def focus
      set_focus(Qt::OtherFocusReason)
    end
    
    def activate
      Kodr::Action["file_save"].set_enabled(document.is_modified)
      editor_set.active_editor = self
    end
    
    def clone!
      new_editor = EditorSet.active.open_url(nil)
      new_doc = new_editor.document
      new_doc.set_plain_text(to_plain_text)
      new_editor.set_mode(mode)
      new_editor.set_cursor_position(0, 0)
    end
    
    def rename
      old_filename = document.url.path_or_url
      if document.save_as && document.url.path_or_url != old_filename
        FileUtils.rm old_filename
        update_label
      end
    end
    
    def close
      # return false unless document.close_url # TODO
      editor_set.remove_editor(self)
      true
    end
  end
end
