include_dirs = %w(config lib models)
include_dirs.each do |dir|
  $:.unshift(File.join(File.dirname(__FILE__), dir))
end

require 'sinatra/base'

require 'sass'
require 'compass'
require 'coffee-script'
require 'kramdown'
require 'erb'
require 'slim'
require 'dalli'

require 'active_support/core_ext'

require 'dropbox-api'
require 'simplenote'

class NerdJersey < Sinatra::Base
  require 'pry' if settings.development?

  # Libraries to include
  require 'settings'
  require 'cache'
  require 'run_later'

  # Models to include
  require 'document_store' if Settings.document_store
  require 'document'
  require 'article'
  require 'page'

  configure do
    Compass.add_project_configuration(File.join(root, 'config', 'compass.config'))
    # Slim::Engine.set_default_options :sections => true
    set :cache, Dalli::Client.new
    enable :logging
  end

  before do
    # Set cache headers
    response.headers['Cache-Control'] = 'public, max-age=300'

    # Redirect to non-trailing slash, if slash exists
    if request.path_info =~ /\/$/ && request.path_info != '/'
      redirect request.path_info.gsub(/\/$/, '')
    end

    # See if config.yml is loaded and display error if not
    if !Settings.document_store
      params[:message] = 'There is no config.yml file. Please see the README for instructions on setting up this file.' 
      request.path_info = '/error'
    end

  end

  get '/' do
    check_deltas
    articles = Article.all
    slim :index, :locals => { :articles => articles }
  end

  get '/clear' do
    settings.cache.flush_all
    erb 'cache cleared'
  end

  get '/refresh' do
    settings.cache.flush_all
    Article.all
    Page.all
    redirect '/'
  end

  get '/error' do
    params[:message]
  end

  get '/stylesheets/:name.css' do
    content_type 'text/css', :charset => 'utf-8'
    scss(:"stylesheets/#{params[:name]}", Compass.sass_engine_options )
  end

  get '/javascripts/:name.js' do
    content_type "text/javascript", :charset => 'utf-8'
    coffee :"javascripts/#{params[:name]}"
  end

  get '/:slug' do
    check_deltas
    content_type 'text/html', :charset => 'utf-8'
    page = Page.find( '/pages/' + params[:slug] )
    if page
      markdown page.body,
        :layout => :page, :layout_engine => :slim,
        :locals => { :page => page }
    else
      raise Sinatra::NotFound
    end
  end

  get '/articles/:slug' do
    check_deltas
    content_type 'text/html', :charset => 'utf-8'
    # date = [ params[:year], params[:month], params[:day] ].join('-')
    article = Article.find( '/articles/' + params[:slug] )
    if article
      markdown article.body,
        :layout => :article, :layout_engine => :slim,
        :locals => { :article => article }
    else
      raise Sinatra::NotFound
    end
  end

  not_found do
    slim :err_404
  end

  error do
    slim :err_500
  end


  helpers do

    def partial(template, *args)
      template_array = template.to_s.split('/')
      template = template_array[0..-2].join('/') + "/_#{template_array[-1]}"
      options = args.last.is_a?(Hash) ? args.pop : {}
      options.merge!(:layout => false)
      if collection = options.delete(:collection) then
        collection.inject([]) do |buffer, member|
          buffer << slim(:"#{template}", options.merge(:layout =>
          false, :locals => {template_array[-1].to_sym => member}))
        end.join("\n")
      else
        slim(:"#{template}", options)
      end
    end

    def check_deltas
      # Run delta check on document store if necessary
      if Cache.get('nerdjersey::last_updated_at') && Cache.get('nerdjersey::last_updated_at') < Settings.delta_check_after.minutes.ago
        run_later do
          DocumentStore.delta
        end
      end
    end

  end

  run! if app_file == $0
end
