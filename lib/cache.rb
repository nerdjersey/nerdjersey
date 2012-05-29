module Cache
  extend self

  @@client ||= Dalli::Client.new

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
