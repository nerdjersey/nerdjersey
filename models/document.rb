class Document < Application
  attr_reader :body, :metadata
  
  @@client ||= Dropbox::API::Client.new(:token  => DROPBOX_CLIENT_TOKEN, :secret => DROPBOX_CLIENT_SECRET)
  
  def self.fetch( file_name )
    body, metadata = parsed_file( file_path(file_name) )
    
    db_metadata = DocumentCache.find( file_path(file_name) )
    
    metadata.date ||= db_metadata.modified
    # metadata.date = metadata.date? ? Time.parse(metadata.date) : Time.parse(db_metadata.modified)
    metadata.date = Time.parse(metadata.date)
    metadata.title ||= file_name.gsub('.md', '')
    metadata.slug ||= parameterize(metadata.title)
    
    # metadata.permalink ||= file_path(file_name).gsub(/(#{path}\/|.md)/, '').gsub('-', '/') + '/' + metadata.slug
    metadata.permalink = "/#{path}/" + metadata.slug
    # metadata.date = Date.parse file_name if path == 'articles'
    
    settings.cache.set( metadata.permalink, self.new(body, metadata) )
    
    # self.new(body, metadata)
    settings.cache.get( metadata.permalink )
    
  rescue Dropbox::API::Error::NotFound
    return false
  end
  
  def self.find_all()
    list = []
    
    DocumentCache.ls( path ).each do |f|
      file_name = f.path.gsub(/(#{path}\/|.md)/, '')
      list << fetch( file_name )
    end
    
    list.delete_if { |a| a.date > Time.now }
    list.sort! { |a,b| b.date <=> a.date }
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
      # super
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


  protected
    
  def self.remote_file(file_path)
    DocumentCache.download file_path
  end
    
  def self.parsed_file(file_path)
    DocumentParser.parse( remote_file( file_path ) )
  end
    
  def self.file_path(file_name)
    "#{self.path}/#{file_name}.md"
  end

end
