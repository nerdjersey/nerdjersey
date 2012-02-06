class DocumentCache
  
  @@client ||= Dropbox::API::Client.new(:token  => DROPBOX_CLIENT_TOKEN, :secret => DROPBOX_CLIENT_SECRET)
  
  def self.ls( path )
    settings.cache.get( path ) || settings.cache.set( path, @@client.ls(path) )
  end
  
  def self.download( file_path )
    settings.cache.get( file_path ) || settings.cache.set( file_path, @@client.download(file_path) )
  end
  
  def self.find( file_path )
    settings.cache.get( file_path + '-meta' ) || settings.cache.set( file_path + '-meta', @@client.find(file_path) )
  end
  
end