class Article < Document

  def self.doc_type
    Settings.articles_folder
  end

end
