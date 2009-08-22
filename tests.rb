require 'awesomephp.rb'
require "test/unit"

class TestAwesomePHP < Test::Unit::TestCase
  
  def tests_equal
    assert_equal("$ho->print(\"joie\");\n", AwesomePHP.new('ho.print("joie")', false, true).instance_variable_get(:@c) )
    assert_equal("print(\"joie\");\n", AwesomePHP.new('print("joie")', false, true).instance_variable_get(:@c) )
    assert_equal("function __construct(){\npass();\n}\n\n", AwesomePHP.new("def init():
      pass()", false, true).instance_variable_get(:@c) )
  end

end