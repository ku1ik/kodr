module Kodr
  module Textmate
    module SyntaxHighlighting
      def self.included(base)
        base.extend(ClassMethods)
        base.class_eval do
          attr_accessor :syntax
          attr_reader :highlighter
        end
      end

      module ClassMethods

        def load_syntaxes
          syntaxes = {}
          filenames = Dir[File.expand_path("~/.kodr/Bundles/*/Syntaxes/*.plist")] + Dir[File.expand_path("~/.kodr/Bundles/*/Syntaxes/*.tmLanguage")]
          filenames.each do |syntax_file|
            syntax = Textpow::SyntaxNode.new(Plist::parse_xml(File.read(syntax_file).gsub("ustring", "string")))
            syntaxes[syntax.name] = syntax
          end
          syntaxes
        end
      
        def syntaxes
          @@syntaxes ||= load_syntaxes
        end
        
        def syntax_for(filename)
          syntaxes.values.detect { |s| s.fileTypes && s.fileTypes.detect { |ft| filename =~ /#{Regexp.escape(ft)}$/ } }
        end
        
      end
    end
  end
end

