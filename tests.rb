require 'phlower.rb'
require "test/unit"

class TestAwesomePHP < Test::Unit::TestCase
  
  def tests_equal
    assert_equal("$ho->print(\"joie\")", AwesomePHP.new('ho.print("joie")', false, true).instance_variable_get(:@c) )
    assert_equal("print(\"joie\");\n", AwesomePHP.new('print("joie")', false, true).instance_variable_get(:@c) )
    assert_equal("function __construct(){\npass();\n}\n\n", AwesomePHP.new("def init():
      pass()", false, true).instance_variable_get(:@c) )
    assert_equal("$awe = $aw->x()", AwesomePHP.new('awe = aw.x()', false, true).instance_variable_get(:@c) )
    assert_equal("print($aw);\n", AwesomePHP.new('print(aw)', false, true).instance_variable_get(:@c) )
    assert_equal("$arr = array()", AwesomePHP.new("arr = []", false, true).instance_variable_get(:@c) )
    assert_equal("if ($aw->joie()) {\nprint();\n}\n", AwesomePHP.new("if aw.joie():\n  print()", false, true).instance_variable_get(:@c) )
    assert_equal("$aw = new Awesome(\"brilliant!\",2);\n", AwesomePHP.new('aw = Awesome.new("brilliant!",2)', false, true).instance_variable_get(:@c) )
    assert_equal("var $poulet = \"joie\";\n", AwesomePHP.new('@poulet = "joie"', false, true).instance_variable_get(:@c) )
    assert_equal("$this->poulet;\n", AwesomePHP.new('this.poulet', false, true).instance_variable_get(:@c) )
  end

end