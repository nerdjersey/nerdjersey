require 'dropbox-api'
require './lib/settings'

class String
  # Strip leading whitespace from each line that is the same as the 
  # amount of whitespace on the first line of the string.
  # Leaves _additional_ indentation on later lines intact.
  def unindent
    gsub /^#{self[/\A\s*/]}/, ''
  end
end

namespace :nerdjersey do
  namespace :setup do

    desc "Set up Dropbox with initial files/folders"
    task :dropbox do
      puts "Setting up Dropbox..."

      Dropbox::API::Config.app_key = Settings.dropbox_app_key
      Dropbox::API::Config.app_secret = Settings.dropbox_app_secret
      # If you have a single-directory app or "dropbox" if it has access to the whole dropbox
      Dropbox::API::Config.mode = 'sandbox'

      c = Dropbox::API::Client.new(:token => Settings.dropbox_client_token, :secret => Settings.dropbox_client_secret)

      # Set up /articles
      begin
        c.find('articles/')
      rescue Dropbox::API::Error::NotFound
        puts 'Adding articles folder...'
        c.mkdir 'articles'
        puts 'Adding example article...'
        body = <<-BODY.unindent
          title: Oh, Hi!
          slug: published-via-nerdjersey
          ---

          This site is published using [NerdJersey](http://github.com/nerdjersey/nerdjersey). Try it for yourself and change the way you publish, not the way you write.
        BODY
        c.upload 'articles/My First Post.md', body
      end

      # Set up /pages
      begin
        c.find('pages/')
      rescue Dropbox::API::Error::NotFound
        puts 'Adding pages folder...'
        c.mkdir 'pages'
        puts 'Adding example page...'
        body = <<-BODY.unindent
          title: About Me
          slug: about
          ---

          I am one smart cookie.
        BODY
        c.upload 'pages/About.md', body
      end

      puts 'Done!'
    end

    task :simplenote do
      puts "Simplenote implementation isn't ready for prime time yet. Sorry. :)"
    end

  end
end
