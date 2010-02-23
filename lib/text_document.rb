module Kodr
  class TextDocument < Qt::TextDocument
    attr_reader :url
    
    def initialize
      super
      setDocumentLayout(Qt::PlainTextDocumentLayout.new(self))
      setDefaultFont(Qt::Font.new("Envy Code R", 10))
      @url = KDE::Url.new
    end
    
    def open_url(url)
      # TODO check if current dirty
      @url = url
      set_plain_text(File.read(@url.path))
      set_modified(false)
      true
    end
    
    # cursor_for_position
    
    def line(n)
      find_block_by_line_number(n).text
    end
    
    def line_length(n)
      find_block_by_line_number(n).length
    end
    
    def cursor_for(line, column)
      c = Qt::TextCursor.new(self)
      c.move_position(Qt::TextCursor::NextBlock, Qt::TextCursor::MoveAnchor, line)
      c.move_position(Qt::TextCursor::Right, Qt::TextCursor::MoveAnchor, column)
      c
    end
    
    def document_end
      cursor_for(last_block.first_line_number, last_block.length)
    end
    
    def text
      to_plain_text
    end
    
    def [](pos)
      if pos.is_a?(Range)
        start = Qt::TextCursor.new(self)
        start.set_position(pos.begin)
        start.set_position(pos.end, Qt::TextCursor::KeepAnchor)
        start.selected_text.to_s
      else
        character_at(pos) # TODO to_s
      end
    end
    
    def save
      if @url.is_empty
        save_as
      elsif is_modified
        store
      else
        true
      end
    end
    
    def store
      File.open(@url.path, "w") { |f| f.write(to_plain_text) }
      set_modified(false)
    end
    
    def save_as
      filename = KDE::FileDialog::get_save_file_name(@url, "", App.instance, "")
      if filename.blank?
        false
      else
        @url = KDE::Url.new(filename)
        store
        true
      end
    end

    def text_range(line1, col1, line2, col2)
      start = cursor_for(line1, col1)
      end_ = cursor_for(line2, col2)
      self[start.position..end_.position]
    end

    def remove_text_range(line1, col1, line2, col2)
      start = cursor_for(line1, col1)
      end_ = cursor_for(line2, col2)
      start.move_position(Qt::TextCursor::Right, Qt::TextCursor::KeepAnchor, end_.position - start.position)
      start.remove_selected_text
    end

  end
end
