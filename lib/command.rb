module Kodr
  WORD_CHARS = 'a-zA-Z0-9_\?\!'
  
  class Command
    cattr_accessor :commands, :name, :description, :shortcut, :modes, :single_undo_step, :old_cursor_position
    
    self.commands = []
    
    def self.mode(*values)
      modes(*values)
    end
    
    def self.inherited(klass)
      Kodr::Command.commands << klass
      klass.single_undo_step = true
      klass.old_cursor_position = {}
    end
    
    def self.register
      if name && description
        log "registering command: #{name}"
        action = Kodr::App.instance.action_collection.add_action(name)
        action.set_text(description)
        action.set_shortcut(Qt::KeySequence.new(shortcut)) if shortcut
        _self = self
        Kodr::App.instance.connect(action, SIGNAL("triggered()")) { _self.new.trigger }
      else
        log "ignoring command #{self}, name or description missing"
      end
    end
    
    # instance methods
    
    def view
      View.active.kte_view
    end
    
    def document
      view.document
    end
    
    def find_action(name)
      Kodr::App.instance.action_collection.action(name) || view.action_collection.action(name)
    end
    
    def run(env)
      call(env)
    end
    
    def call(env)
      raise RuntimeError.new("You must implement call(env) method!")
    end
    
    def trigger
      if modes.nil? || modes.include?(view.document.mode)
        begin
          view.document.start_editing if single_undo_step
          run(prepare_env)
        rescue => e
          puts "#{e.class}: #{e.message}"
          puts e.backtrace
        ensure
          view.document.end_editing if single_undo_step
        end
        old_cursor_position[view] = view.cursor_position
      else
        if shortcut.to_s.size == 1
          view.insert_text(shortcut)
        end
      end
    end
    
    def prepare_env
      env = {}
      # document end
      doc_end = view.document.document_end
      env.merge!(:document_end_line => doc_end.line, :document_end_column => doc_end.column)
      # cursor position
      cursor_position = view.cursor_position
      env.merge!(:line => cursor_position.line, :column => cursor_position.column)
      # cursor position changed?
      env.merge!(:cursor_position_changed => cursor_position != old_cursor_position[view])
      env.merge!(:char_before_cursor => document.character(KTextEditor::Cursor.new(cursor_position.line, cursor_position.column - 1)).to_s)
      # word before cursor
      if cursor_position.column > 0
        line_to_cursor = document.line(cursor_position.line)[0..cursor_position.column-1]
        match = /([#{WORD_CHARS}]+)$/.match(line_to_cursor)
        if match
          env.merge!(:word_before_cursor => match[1], :word_before_cursor_start => match.begin(1), :word_before_cursor_end => match.end(1))
        end
      end
      env
    end
  
    def selected_lines
      range = view.selection_range
      if range.is_valid
        start_line, end_line = range.start.line, range.end.line
        end_line -= 1 if range.end.column == 0
      else
        start_line = end_line = view.cursor_position.line
      end
      [start_line, end_line, range]
    end
    
  end

  class DocumentCommand < Command
    def run(env)
      env[:document_text] = view.document.text
      if view.selection
        env[:selected_text] = view.selection_text
      end
      response = call(env)
      if response
        view.remove_selection_text
        view.insert_text(response)
      end
    end
  end
  
end
