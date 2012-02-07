class DocumentCache < Application
  
  @@client ||= Dropbox::API::Client.new(:token  => DROPBOX_CLIENT_TOKEN, :secret => DROPBOX_CLIENT_SECRET)
  
  def self.ls( path )
    path_key = parameterize(path)
    # settings.cache.get( path_key ) || settings.cache.set( path_key, @@client.ls(path) )
    if !settings.cache.get( path_key )
      settings.cache.set( path_key, @@client.ls(path) )
    end
    return settings.cache.get( path_key )
  end
  
  def self.download( file_path )
    file_path_key = parameterize(file_path)
    # settings.cache.get( file_path ) || settings.cache.set( file_path, @@client.download(file_path) )
    if !settings.cache.get( file_path_key )
      settings.cache.set( file_path_key, @@client.download(file_path) )
    end
    return settings.cache.get( file_path_key )
  end
  
  # def self.find( file_path )
  #   file_path_key = parameterize(file_path)
  #   if !settings.cache.get( file_path_key + '-meta' )
  #     settings.cache.set( file_path_key + '-meta', @@client.find(file_path) )
  #   end
  #   return settings.cache.get( file_path_key + '-meta' )
  #   # settings.cache.get( file_path + '-meta' ) || settings.cache.set( file_path + '-meta', @@client.find(file_path) )
  # end
  
  # Instead of using @@client.find
  def self.find( file_path )
    path = file_path.match(/\/*(.+)\//)[1]
    ls( path ).find { |d| d[:path] =~ /#{file_path.gsub(/\//, '\/').gsub(/\./, '\.')}/ }
  end
  
  def self.check_status
    to_check = ['articles', 'pages']
    to_check.each do |p|
      new_ls = @@client.ls(p)
      if new_ls.hash != settings.cache.get(p).hash
        settings.cache.set( path_key, new_ls )
      end
    end
  end
  
end