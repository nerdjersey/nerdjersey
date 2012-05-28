ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'
require 'nutrasuite'

require_relative './../app'

class NerdJersey
  module Test
    module Methods

      def app
        NerdJersey
      end
    
    end
  end
end
