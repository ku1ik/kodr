module Kodr
  WORD_CHARS = 'a-zA-Z0-9_\?'
  
  class Action < KDE::Action
    cattr_accessor :all, :groups, :instance
    cattr_accessor :name, :description, :shortcut, :alternate_shortcut, :icon, :modes, :group, :checked, :enabled, :checkable,
                   :single_undo_step, :old_cursor_position
    
    self.all = []
    self.groups = {}
    
    def self.[](name)
      App.instance.action(name) || EditorSet.active.active_editor.view.action(name)
    end
    
    def self.mode(*values)
      modes(*values)
    end
    
    def self.inherited(klass)
      Kodr::Action.all << klass
      klass.single_undo_step = true
      klass.enabled = true
    end
    
    def self.register
      if name && description
        log "registering action: #{name}"
        action = new(App.instance)
        action.register
        self.instance = action
      else
        log "ignoring action #{self}, name or description missing"
      end
    end
    
    # instance methods
    
    def register
      set_text(description)
      if s = shortcut
        if s.respond_to?(:call) #TODO: move action requiring to App
          s = s.call
        end
        kshortcut = KDE::Shortcut.new(s)
        if alternate_shortcut
          kshortcut.set_alternate(Qt::KeySequence.new(alternate_shortcut))
        end
        set_shortcut(kshortcut)
      end
      if icon
        set_icon(KDE::Icon.new(icon))
      end
      if group
        set_checkable(true)
        g = (groups[group] ||= Qt::ActionGroup.new(Kodr::App.instance))
        set_action_group(g)
        if checked
          set_checked(true)
        end
      end
      unless enabled
        set_enabled(false)
      end
      if checkable
        set_checkable(true)
      end
      _self = self
      App.instance.connect(self, SIGNAL("triggered()")) { _self.trigger }
      App.instance.action_collection.add_action(name, self)
    end
    
    def editor
      EditorSet.active.active_editor
    end
    
    def document
      editor.document
    end
    
    def cursor
      editor.text_cursor
    end
    
    def run
      call
    end
    
    def call
      raise RuntimeError.new("You must implement call method!")
    end
    
    def trigger
      if modes.nil? || modes.include?(document.mode)
        begin
          if single_undo_step
            @_start_editor = editor
            editor.cursor.begin_edit_block
          end
          run
        rescue => e
          puts "#{e.class}: #{e.message}"
          puts e.backtrace
        ensure
          if single_undo_step
            raise "Action #{name} changed active editor while being in editing transaction!" if @_start_editor != editor
            editor.cursor.end_edit_block
          end
          @cursor_position_changed_at = editor.cursor_position_changed_at
        end
      else
        if shortcut.to_s.size == 1
          view.insert_text(shortcut)
        end
      end
    end
  end

  class EditorAction < Action

    def run
      @cache = {}
      super
    end
    
    def selected_text
      raise "Not implemented"
    end
    
    def cursor_position_changed?
      @cache[:cursor_position_changed?] ||= editor.cursor_position_changed_at != @cursor_position_changed_at
    end
    
    # def char_before_cursor
      # @cache[:char_before_cursor] ||= document[cursor_position.position-1]
    # end
    
    def word_before_cursor
      unless @cache.key?(:word_before_cursor)
        if cursor.column > 0
          line_before_cursor = document.line(cursor.line)[0..cursor.column-1]
          if match = /([#{WORD_CHARS}]+)$/.match(line_before_cursor)
            w = Word.new(match[1])
            w.position = match.begin(1)
            @cache[:word_before_cursor] = w
          end
        end
      end
      @cache[:word_before_cursor]
    end
    
    def word_after_cursor
      unless @cache.key?(:word_after_cursor)
        if cursor.column < document.current_line.size
          line_after_cursor = document.line(cursor.line)[cursor.column..-1]
          if match = /^([#{WORD_CHARS}]+)/.match(line_after_cursor)
            w = Word.new(match[1])
            w.position = cursor.column + match.begin(1)
            @cache[:word_after_cursor] = w
          end
        end
      end
      @cache[:word_after_cursor]
    end
    
    def word_under_cursor
      unless @cache.key?(:word_under_cursor)
        if word_before_cursor || word_after_cursor
          w = Word.new(word_before_cursor.to_s + word_after_cursor.to_s)
          w.position = word_before_cursor.try(:position) || word_after_cursor.try(:position)
          @cache[:word_under_cursor] = w
          # env[:word_under_cursor] = env[:word_before_cursor].to_s + env[:word_after_cursor].to_s
          # env[:word_under_cursor_start] = env[:word_before_cursor_start] || env[:word_after_cursor_start]
          # env[:word_under_cursor_end] = env[:word_after_cursor_end] || env[:word_before_cursor_end]
        end
      end
      @cache[:word_under_cursor]
    end

  #   def selected_lines
  #     range = view.selection_range
  #     if range.is_valid
  #       start_line, end_line = range.start.line, range.end.line
  #       end_line -= 1 if range.end.column == 0
  #     else
  #       start_line = end_line = view.cursor_position.line
  #     end
  #     [start_line, end_line, range]
  #   end
  end
  
  class DocumentAction < EditorAction
    def run
      response = call
      if response
        view.remove_selection_text
        view.insert_text(response)
      end
    end
  end
  
end
