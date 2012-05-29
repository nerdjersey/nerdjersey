require 'yaml'

module Settings
  extend self

  CONFIG_FILE_PATH = './config/config.yml'

  def method_missing( name )
    if !@settings
      file = File.open CONFIG_FILE_PATH
      contents = file.read
      file.close
      @settings = YAML.load(contents)
    end
    method = name.to_s
    if @settings.include? method
      @settings[method]
    else
      nil
    end
  end

end
