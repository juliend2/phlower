require 'awesomephp.rb'
require "test/unit"

class TestAwesomePHP < Test::Unit::TestCase
  
  def tests_equal
    assert_equal('print("joie");', AwesomePHP.new('print("joie")', false, true) )
  end

end