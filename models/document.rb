class Document < Base

  attr_reader :body, :metadata

  def self.fetch( file_path )
    body, metadata = FileCabinet.parse( path, file_path )

    settings.cache.set( metadata.permalink, self.new(body, metadata) )
    settings.cache.get( metadata.permalink )

  rescue Dropbox::API::Error::NotFound
    return false
  end

  def self.find_all()
    documents = []
    FileCabinet.list( path ).each do |f|
      documents << fetch( f.path )
    end

    documents.delete_if { |a| a.date > Time.now }
    documents.sort! { |a,b| b.date <=> a.date }
  end

  def self.find( slug )
    if !settings.cache.get( slug )
      find_all
    end
    settings.cache.get( slug )
  end

  def initialize( body, metadata = {} )
    @body = body
    @metadata = metadata
  end

  def method_missing( name, *args, &blk )
    if args.empty? && blk.nil? && @metadata.has_key?(name)
      @metadata[name]
    else
      return false
    end
  end

  def [](meta)
    if @metadata.has_key?(meta)
      @metadata.fetch(meta)
    else
      nil
    end
  end

  def self.path
    raise NotImplementedError
  end

  # TODO: Add category support
  # def category
  #   # @category ||= Category.find(@metadata[:category])
  #   @category ||= @metadata[:category]
  # end


  private

  def self.parsed_file( file_path )
    FileCabinet.parse file_path
  end

end