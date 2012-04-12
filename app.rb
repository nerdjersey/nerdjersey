require 'sinatra/base'
require "sinatra/config_file"

class NerdJersey < Sinatra::Base
  register Sinatra::ConfigFile

  config_file './config/config.yml'

  require 'sass'
  require 'compass'
  require 'coffee-script'
  require 'kramdown'
  require 'erb'
  require 'slim'
  require 'dalli'

  require 'active_support/core_ext'

  require 'dropbox-api'
  require "simplenote"

  if settings.development?
    require 'pry'
  end

  # Libs to include
  require './lib/run_later'


  # Models to include
  require './models/base'
  require './models/document_parser'
  require './models/document_cache'
  require './models/document'
  require './models/article'
  require './models/page'

  configure do
    Compass.add_project_configuration(File.join(root, 'config', 'compass.config'))
    # Slim::Engine.set_default_options :sections => true
    set :cache, Dalli::Client.new
  end

  before do
    # Kill trailing slash if it exists
    if request.path_info =~ /\/$/ && request.path_info != '/'
      request.path_info.gsub(/\/$/, '')
    end
  end

  get '/' do
    articles = Article.find_all
    slim :index, :locals => { :articles => articles }
  end

  get '/pry' do
    binding.pry
    render :text => 'hi'
  end

  get '/:name.ico' do
    raise Sinatra::NotFound
  end

  get '/clear' do
    settings.cache.flush_all
    erb 'cache cleared'
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

  end

  run! if app_file == $0
end
