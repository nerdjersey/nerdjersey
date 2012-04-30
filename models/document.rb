class Document

  attr_reader :remote_key, :body, :metadata

  def self.all
    if !Settings.cache.get( doc_type )
      documents = DocumentStore.list( doc_type ) || []

      documents.delete_if { |a| a.date > Time.now }
      documents.delete_if { |a| a.published == false || a.publish == false }
      documents.sort! { |a,b| b.date <=> a.date }

      documents.each do |d|
        Settings.cache.set( d.permalink, d )
      end

      Settings.cache.set( doc_type, documents )
    end
    Settings.cache.get( doc_type )
  end

  def self.find( permalink )
    if !Settings.cache.get( permalink )
      all
    end
    Settings.cache.get( permalink )
  end

  def initialize( remote_key, document_data )
    @remote_key = remote_key
    body, metadata = DocumentStore.parse(document_data)
    @body = body
    @metadata = metadata
  end

  def method_missing( name, *args, &blk )
    if args.empty? && blk.nil? && self.metadata.has_key?(name)
      self.metadata[name]
    else
      return nil
    end
  end

  def [](meta)
    if self.metadata.has_key?(meta)
      self.metadata.fetch(meta)
    else
      nil
    end
  end

  def self.doc_type
    raise NotImplementedError
  end

  # TODO: Add category/tag support
  # def category
  #   # @category ||= Category.find(@metadata[:category])
  #   @category ||= @metadata[:category]
  # end

end
