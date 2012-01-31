require 'sinatra'
require 'sass'
require 'compass'
require 'coffee-script'
require 'kramdown'
require 'erb'
require 'slim'
require 'dropbox-api'

require "sinatra/reloader" if development?

# Config to include
require './config/dropbox-example'

# Models to include
require './models/document_parser'
require './models/document'
require './models/article'
require './models/page'

configure do
  Compass.add_project_configuration(File.join(Sinatra::Application.root, 'config', 'compass.config'))
  # Slim::Engine.set_default_options :sections => true
end

before do
  # Kill trailing slash if it exists
  if request.path_info =~ /\/$/ && request.path_info != '/'
    redirect request.path_info.gsub(/\/$/, ''), 303
  end
end

get '/' do
  articles = Article.find_all
  slim :index, :locals => { :articles => articles }
end

get '/stylesheets/:name.css' do
  content_type 'text/css', :charset => 'utf-8'
  scss(:"stylesheets/#{params[:name]}", Compass.sass_engine_options )
end

get '/javascripts/:name.js' do
  content_type "text/javascript", :charset => 'utf-8'
  coffee :"javascripts/#{params[:name]}"
end

get '/:title' do
  content_type 'text/html', :charset => 'utf-8'
  page = Page.find( params[:title] )
  if page
    markdown page.body,
      :layout => :page, :layout_engine => :slim,
      :locals => { :page => page }
  else
    raise Sinatra::NotFound
  end
end

get '/:year/:month/:day/?:slug?' do
  content_type 'text/html', :charset => 'utf-8'
  date = [ params[:year], params[:month], params[:day] ].join('-')
  article = Article.find( date )
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