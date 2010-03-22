module Kodr
  def settings
    @@settings ||= YAML.load_file(File.expand_path("~/.kodr/settings.yml")) rescue Hash.new
  end
  module_function :settings
end
