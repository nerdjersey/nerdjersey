class Document
  attr_reader :body, :metadata
  
  @@client ||= Dropbox::API::Client.new(:token  => DROPBOX_CLIENT_TOKEN, :secret => DROPBOX_CLIENT_SECRET)
  
  def self.find(file_name)
    body, metadata = parsed_file( file_path(file_name) )
    metadata.slug = parameterize(metadata[:title])
    metadata.permalink = file_path(file_name).gsub(/(#{path}\/|.md)/, '').gsub('-', '/') + '/' + metadata.slug
    metadata.date = Date.parse file_name if path == 'articles'
    
    self.new(body, metadata)
    
  rescue Dropbox::API::Error::NotFound
    return false
  end
  
  def self.find_all()
    list = []
    
    DocumentCache.ls( path ).each do |f|
      file_name = f.path.gsub(/(#{path}\/|.md)/, '')
      list << find(file_name)
    end
    
    list.delete_if { |a| a.date > Time.now }
    list.sort! { |a,b| b.date <=> a.date }
  end
  
  def initialize(body, metadata = {})
    @body = body
    @metadata = metadata
  end
  
  def method_missing(name, *args, &blk)
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
  
  def self.parameterize(string, sep = '-')
    require 'iconv'
    # replace accented chars with their ascii equivalents
    parameterized_string = Iconv.iconv('ascii//ignore//translit', 'utf-8', string)[0]
    # Turn unwanted chars into the separator
    parameterized_string.downcase!.gsub!(/[^a-z0-9\-_]+/, sep)
    unless sep.nil? || sep.empty?
      re_sep = Regexp.escape(sep)
      # No more than one of the separator in a row.
      parameterized_string.gsub!(/#{re_sep}{2,}/, sep)
      # Remove leading/trailing separator.
      parameterized_string.gsub!(/^#{re_sep}|#{re_sep}$/, '')
    end
    parameterized_string.downcase
  end

end
