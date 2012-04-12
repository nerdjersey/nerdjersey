require 'yaml'

class DropboxDrawer < Base

  Dropbox::API::Config.app_key = settings.dropbox_app_key
  Dropbox::API::Config.app_secret = settings.dropbox_app_secret
  Dropbox::API::Config.mode = 'sandbox' # if you have a single-directory app or "dropbox" if it has access to the whole dropbox

  @@client ||= Dropbox::API::Client.new(:token => settings.dropbox_client_token, :secret => settings.dropbox_client_secret)

  def self.list( path )
    path_key = path.parameterize
    if !settings.cache.get( path_key )
      settings.cache.set( path_key, @@client.ls(path) )
    end
    return settings.cache.get( path_key )
  end

  def self.find( file_path )
    file_path_key = file_path.parameterize
    if !settings.cache.get( file_path_key )
      settings.cache.set( file_path_key, @@client.download(file_path) )
    end
    return settings.cache.get( file_path_key )
  end

  def self.search( file_path )
    path = file_path.match(/\/*(.+)\//)[1]
    list( path ).find { |d| d[:path] =~ /#{file_path.gsub(/\//, '\/').gsub(/\./, '\.')}/ }
  end

  def self.parse( path, file_path )
    contents = self.find file_path
    if contents.include?('---') && contents[0..25].include?(':')
      meta, body = contents.split(/\r?\n---+\r?\n/, 2)
      meta = YAML.load(meta)
      metadata = Hashie::Mash.new(meta)
    else
      body = contents
      metadata = Hashie::Mash.new
    end

    file_name = file_path.gsub(/(#{path}\/|.md)/, '')
    db_metadata = FileCabinet.search( file_path )

    metadata.date ||= db_metadata.modified
    metadata.date = Time.parse(metadata.date)
    metadata.title ||= file_name.gsub('.md', '')
    metadata.slug = (metadata.slug.nil? ? metadata.title : metadata.slug).parameterize
    metadata.permalink = "/#{path}/" + metadata.slug

    return body, metadata

  rescue Dropbox::API::Error::NotFound
    return false
  end

end