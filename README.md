# Nerd Jersey

Nerd Jersey is a blogging platform designed specifically for the wants and needs of developers (namely this developer) and is inspired by Marco Arment's [SecondCrack](http://github.com/marcoarment/secondcrack) (PHP) and Joe Hewitt's [Nerve](http://github.com/joehewitt/nerve) (NodeJS).

The main goal of Nerd Jersey is to be a Sinatra-based, Dropbox-driven, Markdown-formatted blogging platform. Yes, a lot like http://scriptogr.am, but hopefully more powerful.

## Initial Setup

All the gems are listed in the `Gemfile` so after forking and cloning, run `bundle` in the console from the application directory.

### Dropbox

The first real step is to get Dropbox set up. To do so, create and app here: [https://www.dropbox.com/developers/apps]( https://www.dropbox.com/developers/apps)

Once you have it, replace the necessary values in `config/dropbox-example.rb` and rename the file to `config/dropbox.rb`.

    Dropbox::API::Config.app_key    = 'AAAAAAAAAAAAAAA'
    Dropbox::API::Config.app_secret = 'BBBBBBBBBBBBBBB'

Back at the console, run

    rake dropbox:authorize

When you call this Rake task, it will ask you to provide the consumer key and secret. Afterwards it will present you with an authorize url on Dropbox.

Simply go to that url, authorize the app, then press `ENTER` in the console.

The rake task will output provide the client token and client secret, which you can now add to `config/dropbox.rb`.

    DROPBOX_CLIENT_TOKEN = 'XXXXXXXXXXXXXXX'
    DROPBOX_CLIENT_SECRET = 'YYYYYYYYYYYYYYY'

Congratulations! Dropbox is set up.

### File Structure

Now, in your Dropbox, you should see an `Apps` folder with a subfolder named after your Dropbox application. You'll need to create two subfolders `articles` and `pages` as shown below.

![Nerd Jersey File Structure](http://nerdjersey.s3.amazonaws.com/images/Nerd%20Jersey%20File%20Structure.png)

### Content Creation

Articles should have filenames in the `YYYY-MM-DD.md` format. Pages are named after the slug you would like them to use, i.e. `about.md`. Meta information is separated from content with at least three minus signs (or hyphens) `---`. The `title` metadata is required for all articles and pages and articles may optionally have tags, as shown in this example.

    title: My First Blog Post
    tags:
      - Winner
      - Chicken Dinner
    ---
    
    Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

