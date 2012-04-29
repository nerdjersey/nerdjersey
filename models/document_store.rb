require './models/document_stores/dropbox'
require './models/document_stores/simple_note'

class DocumentStore

  @@strategy = "DocumentStore::#{Settings.strategy.classify}Store".constantize

  def self.list( query )
    @@strategy.list( query )
  end

  def self.find( doc_type, query )
    @@strategy.find( doc_type, query )
  end

  def self.search( query )
    @@strategy.search( query )
  end

  def self.parse( document )
    contents = document.contents
    if contents.include?('---') && contents[0..25].include?(':')
      meta, body = contents.split(/\r?\n---+\r?\n/, 2)
      meta = YAML.load(meta)
      metadata = Hashie::Mash.new(meta)
    else
      body = contents
      metadata = Hashie::Mash.new
    end

    metadata = parse_metadata( document, metadata )

    return body, metadata

  rescue Dropbox::API::Error::NotFound
    return false
  end

  def self.parse_metadata( document, metadata )
    @@strategy.parse_metadata( document, metadata )
  end

end
