class FileCabinet < Base

  @@strategy = "#{settings.strategy.classify}Drawer".constantize

  def self.list( query )
    @@strategy.list( query )
  end

  def self.find( query )
    @@strategy.find( query )
  end

  def self.search( query )
    @@strategy.search( query )
  end

  def self.parse( doc_type, query )
    @@strategy.parse( doc_type, query )
  end

end
