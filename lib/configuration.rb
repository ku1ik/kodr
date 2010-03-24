module Kodr
  class Configuration
    attr_reader :bundles
    
    def initialize
      load_settings
      load_bundles
    end
    
    def load_settings
      log "loading user settings"
      @settings = YAML.load_file(File.expand_path("~/.kodr/settings.yml")) rescue Hash.new
    end
    
    def load_bundles
      log "loading bundles"
      @bundles = Bundles.new
    end
    
    def method_missing(name, *args)
      @settings[name] || @settings[name.to_s]
    end
    
    class Bundles
      attr_reader :syntaxes
      
      def initialize
        load_syntaxes
        load_preferences
        @score_manager = Textpow::ScoreManager.new
      end
      
      def load_syntaxes
        log "loading syntaxes"
        @syntaxes = {}
        filenames = Dir[File.expand_path("~/.kodr/Bundles/*/Syntaxes/*.plist")] + Dir[File.expand_path("~/.kodr/Bundles/*/Syntaxes/*.tmLanguage")]
        filenames.each do |syntax_file|
          syntax = Textpow::SyntaxNode.new(Plist::parse_xml(File.read(syntax_file).gsub("ustring", "string")))
          if syntax.fileTypes
            @syntaxes[syntax.name] = syntax
          end
        end
      end
      
      def load_preferences
        log "loading preferences"
        @increase_indent_patterns = {}
        @decrease_indent_patterns = {}
        @smart_typing_pairs = {}
        filenames = Dir[File.expand_path("~/.kodr/Bundles/*/Preferences/*.plist")] + Dir[File.expand_path("~/.kodr/Bundles/*/Preferences/*.tmPreferences")]
        filenames.each do |filename|
          prefs = Plist::parse_xml(File.read(filename).gsub("ustring", "string"))
          settings = prefs["settings"]
          if inc_ind_pat = settings["increaseIndentPattern"]
            @increase_indent_patterns[prefs["scope"]] = inc_ind_pat
          end
          if dec_ind_pat = settings["decreaseIndentPattern"]
            @decrease_indent_patterns[prefs["scope"]] = dec_ind_pat
          end
          if smart_pairs = settings["smartTypingPairs"]
            @smart_typing_pairs[prefs["scope"]] = smart_pairs
          end
        end
      end
      
      def find_pattern(where, scope)
        best = nil
        best_score = 0
        where.keys.each do |s|
          score = @score_manager.score(s, scope)
          if score > best_score
            best_score, best = score, s
          end
        end
        if pattern = where[best]
          Regexp.new(pattern)
        end
      end
      
      def increase_indent_pattern(scope)
        find_pattern(@increase_indent_patterns, scope)
      end
      
      def decrease_indent_pattern(scope)
        find_pattern(@decrease_indent_patterns, scope)
      end
      
      def smart_typing_pairs(scope)
        find_pattern(@smart_typing_pairs, scope) || []
      end
    end
  end
end

$configuraton = Kodr::Configuration.new

def config
  $configuraton
end
