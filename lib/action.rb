module Kodr
  
  class Action
    @actions = []
    class << self; attr_reader :actions; end
    
    # class methods
    
    def self.name(value)
      @name = value
    end
    
    def self.description(value)
      @description = value
    end
    
    def self.shortcut(value)
      @shortcut = value
    end
    
    def self.single_undo_step(value)
      @single_undo_step = value
    end
    
    def self.inherited(klass)
      actions << klass
      klass.single_undo_step true
    end
    
    def self.register
      puts "Registering action: #{@name}"
      action = Kodr::App.instance.action_collection.add_action(@name)
      action.set_text(@description)
      action.set_shortcut(Qt::KeySequence.new(@shortcut))
      _self = self
      Kodr::App.instance.connect(action, SIGNAL("triggered()")) { _self.new.trigger }
    end
    
    # instance methods
    
    def view
      View.active.kte_view
    end
    
    def single_undo_step
      self.class.class_eval "@single_undo_step"
    end
    
    def run
      raise RuntimeError.new("You must implement run method!")
    end
    
    def trigger
      p single_undo_step
      view.document.start_editing if single_undo_step
      run
    rescue => e
      puts "#{e.class}: #{e.message}"
      puts e.backtrace
    ensure
      view.document.end_editing if single_undo_step
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

end
