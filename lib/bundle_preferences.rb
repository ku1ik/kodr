module Kodr
  def load_bundle_preferences
    bundle_preferences = Hash.new { |h, k| h[k] = {} }
    filenames = Dir[File.expand_path("~/.kodr/Bundles/*/Preferences/*.plist")] + Dir[File.expand_path("~/.kodr/Bundles/*/Preferences/*.tmPreferences")]
    filenames.each do |filename|
      prefs = Plist::parse_xml(File.read(filename).gsub("ustring", "string"))
      bundle_preferences[prefs["scope"]].merge!(prefs["settings"])
    end
    bundle_preferences
  end
  module_function :load_bundle_preferences
  
  def bundle_preferences
    @@bundle_preferences ||= load_bundle_preferences
  end
  module_function :bundle_preferences
end
