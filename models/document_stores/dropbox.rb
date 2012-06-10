require 'yaml'

class DocumentStore
  class DropboxStore

    Dropbox::API::Config.app_key = Settings.dropbox_app_key
    Dropbox::API::Config.app_secret = Settings.dropbox_app_secret
    # If you have a single-directory app or "dropbox" if it has access to the whole dropbox
    Dropbox::API::Config.mode = 'sandbox'

    def self.client
      @client ||= Dropbox::API::Client.new(:token => Settings.dropbox_client_token, :secret => Settings.dropbox_client_secret)
    end

    def self.delta
      cursor = Cache.get('nerdjersey::cursor')

      response = client.delta( cursor )

      # Get article and page arrays
      articles = Cache.get("/#{Settings.articles_folder}") || []
      pages    = Cache.get("/#{Settings.pages_folder}") || []

      response['entries'].each do |entry|
        path = entry.first
        path = self.clean_path( path )
        meta = entry.last

        # Skip this if it's not a document (an article or page)
        next if !is_document?(path)

        permalink = Cache.get(path)
        old_document = Cache.get(permalink) if permalink

        if meta.nil?
          Cache.set(permalink, nil) if permalink
          Cache.set(path, nil)
          # Find the document in the document array and remove it
          if is_article?( path )
            articles.delete_if { |x| x == old_document } unless permalink.nil?
          elsif is_page?( path )
            pages.delete_if { |x| x == old_document } unless permalink.nil?
          end
        else
          # Create a new document and append it to respective document array
          if is_document?( path ) && !meta.is_dir
            document = self.find( base_folder(path), path )
            Cache.set( document.permalink, document )
            Cache.set( document.remote_key, document.permalink )
            if is_article?( path )
              match = articles.detect { |a| a.remote_key == document.remote_key }
              if match
                articles.delete( match )
              end
              articles << document
            elsif is_page?( path )
              match = pages.detect { |p| p.remote_key == document.remote_key }
              if match
                pages.delete( match )
              end
              pages << document
            end
          end

          Cache.set("/#{Settings.articles_folder}", articles)
          Cache.set("/#{Settings.pages_folder}", pages)
        end

      end

      if response.has_more
        self.delta
      else
        nil
      end

      # Set cursor after above has completed successfully
      Cache.set('nerdjersey::cursor', response.cursor)
      Cache.set('nerdjersey::last_updated_at', Time.now)

    end

    def self.list( path )
      documents = []

      client.ls( path ).each do |f|
        file_path = self.clean_path(f.path)
        document = find( path, file_path )
        documents << document
      end

      documents
    rescue Dropbox::API::Error::NotFound
      return false
    end

    def self.find( doc_type, file_path )
      file_path = self.clean_path(file_path)
      document = client.find(file_path)
      document.contents = client.download(file_path)
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


    private

    def self.base_folder( path )
      path = clean_path path
      folder = path.split('/').first
      folder == path ? nil : folder
    end

    # For some reason Dropbox passes paths back with a leading slash, but won't
    # process them with a leading slash. Awesome.
    def self.clean_path( path )
      path.gsub(/^\//, '')
    end

    def self.is_article?( path )
      Settings.articles_folder == base_folder(path)
    end

    def self.is_page?( path )
      Settings.pages_folder == base_folder(path)
    end

    def self.is_document?( path )
      self.is_page?(path) || self.is_article?(path)
    end

  end
end
