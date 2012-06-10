class Document

  attr_reader :remote_key, :body, :metadata

  def self.all
    if !Cache.get( "/#{doc_type}" )
      DocumentStore.delta
      # documents = DocumentStore.list( doc_type ) || []

      # documents.sort! { |a,b| b.date <=> a.date }

      # documents.each do |d|
      #   Cache.set( d.permalink, d )
      #   # Sets a reference for document lookup
      #   Cache.set( d.remote_key, d.permalink )
      # end

      # Cache.set( "/#{doc_type}", documents )
    end

    cached_documents = Cache.get( "/#{doc_type}" )

    # Remove documents with a date/time later than current date/time
    cached_documents.delete_if { |a| a.date > Time.now }
    # Remove documents with publish/published flag set to false
    cached_documents.delete_if { |a| a.published == false || a.publish == false }
  end

  def self.find( permalink )
    if !Cache.get( permalink )
      all
    end
    Cache.get( permalink )
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
