require 'test_helper'

class DocumentTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods
  include NerdJersey::Test::Methods

  it "does something" do
    something = true

    assert something
  end

end
