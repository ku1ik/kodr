module Kodr
  module Textmate
    class Tag
      attr_accessor :name, :start, :end, :parent, :children
      
      def initialize(attrs={})
        @name = attrs[:name]
        @start = attrs[:start]
        @end = attrs[:end]
        @parent = attrs[:parent]
        @children = []
      end
      
      def reset_start_positions!
        if @name
          @start = 0
        end
        @children.each do |t|
          t.reset_start_positions!
        end
      end
      
      def remove_closed_tags!
        @children.delete_if { |t| t.end }
        @children.each do |t|
          t.remove_closed_tags!
        end
      end
      
      def scope_for_position(pos)
        scope = [@name]
        child = @children.detect do |tag|
          if tag.end
            (tag.start...tag.end).include?(pos)
          else
            pos >= tag.start
          end
        end
        if child
          scope += child.scope_for_position(pos)
        end
        scope
      end
  
      def deep_clone(cloned={})
        return cloned[self] if cloned.key?(self)
        copy = self.clone
        cloned[self] = copy
        copy.children = copy.children.deep_clone
        copy
      end
    end
  end
end
