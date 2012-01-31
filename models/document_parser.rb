require 'yaml'

class DocumentParser

  def self.parse(contents)
    meta, markup = contents.split(/\r?\n---+\r?\n/, 2)
    meta = YAML.load(meta)
    metadata = Hashie::Mash.new(meta)
    
    return markup, metadata
  end

end