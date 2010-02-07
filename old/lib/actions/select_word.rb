module Kodr
  class SelectWordAction < Action
    description "Select Word"
    name "select_word"
    shortcut "Meta+W"
    
    def call(env)
      if env[:word_under_cursor]
        range = KTextEditor::Range.new(env[:line], env[:word_under_cursor_start], env[:line], env[:word_under_cursor_end])
        view.set_selection(range)
      end
    end
  end
end
