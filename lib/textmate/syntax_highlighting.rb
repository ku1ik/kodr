module Kodr
  module Textmate
    module SyntaxHighlighting
      def self.included(base)
        base.extend(ClassMethods)
      end

      def syntax
        self.class.syntaxes[mode]
      end

      module ClassMethods

        def load_syntaxes
          @@syntaxes = {}
          Dir["Bundles/**/Syntaxes/*.plist"].each do |syntax_file|
            syntax = Textpow::SyntaxNode.new(Plist::parse_xml(File.read(syntax_file).gsub("ustring", "string")))
            @@syntaxes[syntax.name] = syntax
          end
        end
      
        def syntaxes
          @@syntaxes
        end

      end
    end
  end
end

