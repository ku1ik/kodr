class KTextEditor::Cursor
  def ==(other)
    other.is_a?(KTextEditor::Cursor) && self.line == other.line && self.column == other.column
  end
end

class KTextEditor::View
  def remove_actions(*names)
    doc = self.xmlguiBuildDocument
    if doc.document_element.is_null
      doc = self.dom_document
    end
    e = doc.document_element
    remove_named_elements(*names, e)
    setXMLGUIBuildDocument(doc)
  end
  
  def remove_named_elements(*names, parent)
    child = parent.first_child
    while !child.is_null
      remove_named_elements(*names, child)
      nchild = child.next_sibling
      if child.is_element
        e = child.to_element
        if names.include?(e.attribute("name"))
          parent.remove_child(child)
        end
      end
      child = nchild
    end
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

class Object
  def try(method)
    send method if respond_to? method
  end
end

class Hash
  def try_dup
    self
  end
end
