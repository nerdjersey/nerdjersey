require 'yaml'

class DocumentStore
  class SimpleNoteStore

    @@client = SimpleNoteApi2.new(Settings.simple_note_username, Settings.simple_note_password)

    def self.list( query )
      raise NotImplementedError
    end

    def self.find( query )
      raise NotImplementedError
    end

    def self.search( query )
      raise NotImplementedError
    end

    def self.parse( path, query )
      raise NotImplementedError
    end

  end
end
