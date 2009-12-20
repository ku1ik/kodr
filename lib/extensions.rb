class KTextEditor::Cursor
  def ==(other)
    other.is_a?(KTextEditor::Cursor) && self.line == other.line && self.column == other.column
  end
end

class Class
  def cattr_accessor(*syms)
    syms.each do |ivar|
      class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
        def self.#{ivar}(obj=:_undefined)
          if obj == :_undefined
            return @#{ivar} if defined?(@#{ivar})
            return nil if self.object_id == #{self.object_id}
            ivar = superclass.#{ivar}
            return nil if ivar.nil?
            @#{ivar} = ivar.try_dup
          else
            @#{ivar} = obj
          end
        end
        
        def self.#{ivar}=(obj)
          @#{ivar} = obj
        end
        
        def #{ivar}
          self.class.#{ivar}
        end
      RUBY
    end
  end
end
