module Kodr
  class CompleteWordAction < EditorAction
    description "Complete word"
    name "complete_word"
    shortcut "Esc"
    icon "debug-execute-from-cursor"
    
    @@completors = {}
    
    def call
      (@@completors[editor] ||= Completor.new(editor, self)).complete
    end
  end

  class Completor
    def initialize(editor, command)
      @editor = editor
      @command = command
    end
    
    def method_missing(name, *args)
      @command.send(name, *args)
    end
    
    def complete
      if cursor_position_changed?
        setup
      end
      if @word_list.empty?
      # textArea.getToolkit().beep()
      else
        next_word = @word_list[@next_word_index]
        @editor.document.remove_text_range(cursor.line, word_before_cursor.position, cursor.line, word_before_cursor.position + word_before_cursor.size)
        @editor.insert_text(next_word)
        @next_word_index = (@next_word_index + 1) % @word_list.size
      end
    end
    
    def setup
      @next_word_index = 0
      if word_before_cursor
        build_word_list
      else
        @word_list = []
      end
    end
    
    def build_word_list
      lines_before = @editor.document.text_range(0, 0, cursor.line, word_before_cursor.position).split("\n").reverse
      lines_after  = @editor.document.text_range(cursor.line, cursor.column, document.document_end.line, document.document_end.column).split("\n")
      text = ""
      [lines_before.size, lines_after.size].max.times do |n|
        text << " " << lines_before[n] if n < lines_before.size
        text << " " << lines_after[n] if n < lines_after.size
      end
      words = text.strip.split(/[^#{WORD_CHARS}]+/).uniq.select { |word| word.start_with?(word_before_cursor) }
      @word_list = words - [word_before_cursor] + [word_before_cursor]
    end
  end
end
