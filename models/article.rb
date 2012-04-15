class Article < Document

  def self.doc_type
    Settings.articles
  end

end
