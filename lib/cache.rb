require 'open-uri'

module Cache
  extend self

  @@client ||= Dalli::Client.new

  def self.set( key, value )
    key = URI::encode( key)
    @@client.set( key, value )
  end

  def self.get( key )
    key = URI::encode( key )
    @@client.get( key )
  end

  def method_missing( name, *args )
    method = name.to_sym
    if args.empty? && @@client.respond_to?( method )
      @@client.send( method )
    elsif !args.empty? && @@client.respond_to?( method )
      @@client.send( method, *args )
    else
      raise NoMethodError
    end
  end

end
