class CompleteWordAction < Kodr::Command
  description "Complete word"
  name "complete_word"
  shortcut "Esc"
  icon "debug-execute-from-cursor"
  
  @@completors = {}
  
  def call(env)
    (@@completors[view] ||= Completor.new(view, self)).complete(env)
  end
end

class Completor
  def initialize(view, command)
    @view = view
    @command = command
  end
  
  def complete(env)
    @env = env
    setup if @env[:cursor_position_changed]
#     unless buffer.editable?
#       textArea.getToolkit().beep()
#       return
#     end
    
    if @word_list.empty?
#       textArea.getToolkit().beep()
    else
      next_word = @word_list[@next_word_index]
      @view.set_selection(KTextEditor::Cursor.new(@env[:line], @env[:word_before_cursor_start]), @env[:word_before_cursor].size, false)
      @view.remove_selection_text
      @view.insert_text(next_word)
      @next_word_index = (@next_word_index + 1) % @word_list.size
    end
  end
  
  def setup
    @next_word_index = 0
    if @env[:word_before_cursor]
      build_word_list
    else
      @word_list = []
    end
  end
  
  def build_word_list
    range = KTextEditor::Range.new(0, 0, @env[:line], @env[:word_before_cursor_start])
    lines_before = @command.document.text(range, false).split("\n").reverse
    range = KTextEditor::Range.new(@env[:line], @env[:column], @env[:document_end_line], @env[:document_end_column])
    lines_after  = @command.document.text(range, false).to_s.split("\n")
    text = ""
    [lines_before.size, lines_after.size].max.times do |n|
      text << " " << lines_before[n] if n < lines_before.size
      text << " " << lines_after[n] if n < lines_after.size
    end
    words = text.strip.split(/[^#{Kodr::WORD_CHARS}]+/).uniq.select { |word| word.start_with?(@env[:word_before_cursor]) }
    @word_list = words - [@env[:word_before_cursor]] + [@env[:word_before_cursor]]
  end
end
