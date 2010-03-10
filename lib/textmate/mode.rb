module Kodr
  class Mode
    cattr_reader :modes
    self.modes = {}
    
    attr_accessor :scope, :syntax, :settings
    
    def self.load_modes
      # load syntaxes
      filenames = Dir["~/.kodr/Bundles/*/Syntaxes/*.plist"] + Dir["~/.kodr/Bundles/*/Syntaxes/*.tmLanguage"]
      filenames.each do |filename|
        syntax = Textpow::SyntaxNode.new(Plist::parse_xml(File.read(filename).gsub("ustring", "string")))
        mode = new(syntax.scopeName)
        mode.syntax = syntax
        modes[mode.scope] = mode
      end
      
      # load preferences
      filenames = Dir["~/.kodr/Bundles/*/Preferences/*.plist"] + Dir["~/.kodr/Bundles/*/Preferences/*.tmPreferences"]
      filenames.each do |filename|
        prefs = Plist::parse_xml(File.read(filename).gsub("ustring", "string"))
        mode = modes[prefs["scope"]]
        if mode
          mode.settings.merge!(prefs["settings"])
        end
      end
    end
    
    def initialize(scope)
      @scope = scope
      @settings = {}
    end
  end
end
