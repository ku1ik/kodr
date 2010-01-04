class KTextEditor::Cursor
  def ==(other)
    other.is_a?(KTextEditor::Cursor) && self.line == other.line && self.column == other.column
  end
end

class KTextEditor::View
  def register_ktexteditor_actions
    Kodr::Action.all.select { |a| a.for_ktexteditor }.each { |a| a.register(self) }
  end
  
  def find_actions_or_submenus(doc, *names)
    found = []
    e = doc.document_element
    [e.elementsByTagName("Action"), e.elementsByTagName("Menu")].each do |list|
      0.upto(list.count-1) do |i|
        elem = list.item(i).to_element
        next if elem.is_null
        if names.include? elem.attribute("name")
          found << elem
        end
      end
    end
    found
  end

  def remove_actions_from_menu(*names)
    doc = self.xmlguiBuildDocument
    doc = doc.document_element.is_null ? self.dom_document : doc
    found = find_actions_or_submenus(doc, *names)
    found.each { |e| e.parent_node.remove_child(e) }
    setXMLGUIBuildDocument(doc)
    found
  end
  
  def insert_action_after(action_name, existing_action_name)
    doc = self.xmlguiBuildDocument
    doc = doc.document_element.is_null ? self.dom_document : doc
    return if find_actions_or_submenus(doc, action_name).size > 0
    existing_action = find_actions_or_submenus(doc, existing_action_name).first
    new_action = doc.create_element("Action")
    new_action.set_attribute("name", action_name)
    new_action.set_attribute("group", existing_action.attribute("group"))
    existing_action.parent_node.insert_after(new_action, existing_action)
    setXMLGUIBuildDocument(doc)
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
    send method if respond_to?(method)
  end
  
  def blank?
    false
  end
end

class Hash
  def try_dup
    self
  end
end

class NilClass
  def blank?
    true
  end
end

class String
  def blank?
    self.strip == ''
  end
end

class Qt::DomElement
  def to_s
    %(<Qt::DomElement name="#{self.tag_name}" attributes=#{self.attributes} />)
  end
end

class Qt::DomAttr
  def to_s
    %(<Qt::DomAttr name="#{self.name}" value="#{self.value}" />)
  end
end

class Qt::DomNamedNodeMap
  def to_s
    items = []
    0.upto(count-1) do |i|
      items << item(i).to_attr.to_s
    end
    %([#{items.join(', ')}])
  end
end
