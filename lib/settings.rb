module Settings
  extend self

  def method_missing( name )
    method = name.to_sym
    if NerdJersey.settings.respond_to?(method)
      NerdJersey.settings.send(method)
    else
      raise NoMethodError
    end
  end

end