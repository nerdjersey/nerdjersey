require 'iconv'

class Application

  def self.parameterize(string, sep = '-')
    # replace accented chars with their ascii equivalents
    parameterized_string = Iconv.iconv('ascii//ignore//translit', 'utf-8', string)[0]
    # Turn unwanted chars into the separator
    parameterized_string.gsub!(/[^a-zA-Z0-9\-_]+/, sep)
    unless sep.nil? || sep.empty?
      re_sep = Regexp.escape(sep)
      # No more than one of the separator in a row.
      parameterized_string.gsub!(/#{re_sep}{2,}/, sep)
      # Remove leading/trailing separator.
      parameterized_string.gsub!(/^#{re_sep}|#{re_sep}$/, '')
    end
    parameterized_string.downcase
  end

end