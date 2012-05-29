class Page < Document

  def self.doc_type
    Settings.pages_folder
  end

end
