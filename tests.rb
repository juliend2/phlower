require 'awesomephp.rb'
require "test/unit"

class TestAwesomePHP < Test::Unit::TestCase
  
  def tests_equal
    assert_equal('$ho->print("joie");', AwesomePHP.new('ho.print("joie")', false, true) )
  end

end