require 'yaml'

class DocumentStore
  class DropboxStore

    Dropbox::API::Config.app_key = Settings.dropbox_app_key
    Dropbox::API::Config.app_secret = Settings.dropbox_app_secret
    # If you have a single-directory app or "dropbox" if it has access to the whole dropbox
    Dropbox::API::Config.mode = 'sandbox'

    @@client ||= Dropbox::API::Client.new(:token => Settings.dropbox_client_token, :secret => Settings.dropbox_client_secret)

    def self.list( path )
      @@client.ls(path)
    rescue Dropbox::API::Error::NotFound
      return false
    end

    def self.find( doc_type, file_path )
      document = @@client.find(file_path)
      document.contents = @@client.download(file_path)
      document.doc_type = doc_type
      Document.new(file_path, document)
    rescue Dropbox::API::Error::NotFound
      return false
    end

    def self.search( file_path )
      path = file_path.match(/\/*(.+)\//)[1]
      list( path ).find { |d| d[:path] =~ /#{file_path.gsub(/\//, '\/').gsub(/\./, '\.')}/ }
    end

    def self.parse_metadata( document, metadata )
      metadata.date ||= document.modified
      metadata.date = Time.parse(metadata.date)
      metadata.title ||= document.path.gsub(/(#{document.doc_type}\/|.md)/, '')
      metadata.slug = (metadata.slug.nil? ? metadata.title : metadata.slug).parameterize
      metadata.permalink = "/#{document.doc_type}/" + metadata.slug

      metadata
    rescue Dropbox::API::Error::NotFound
      return false
    end

  end
end
