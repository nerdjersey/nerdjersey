require 'yaml'

class SimpleNoteDrawer < Base

  @@client = SimpleNoteApi2.new(settings.simple_note_username, settings.simple_note_password)

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