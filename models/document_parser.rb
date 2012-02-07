require 'yaml'

class DocumentParser

  def self.parse(contents)
    if contents.include?('---') && contents[0..25].include?(':')
      meta, markup = contents.split(/\r?\n---+\r?\n/, 2)
      meta = YAML.load(meta)
      metadata = Hashie::Mash.new(meta)
    else
      markup = contents
      metadata = Hashie::Mash.new
    end
    
    return markup, metadata
  end

end