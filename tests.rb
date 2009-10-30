require 'phlower.rb'
require "test/unit"

class TestAwesomePHP < Test::Unit::TestCase
  
  def test_singleline
    # print :
    assert_equal("$ho->print(\"joie\");\n", AwesomePHP.new("ho.print(\"joie\");\n", false, true).instance_variable_get(:@c) )
    assert_equal("$ho->print(\"joie\")", AwesomePHP.new("ho.print(\"joie\")", false, true).instance_variable_get(:@c) )
    assert_equal("print(\"joie\");\n", AwesomePHP.new("print(\"joie\");\n", false, true).instance_variable_get(:@c) )
    assert_equal("print(\"joie\")", AwesomePHP.new("print(\"joie\")", false, true).instance_variable_get(:@c) )
    assert_equal("print($aw);\n", AwesomePHP.new("print(aw);\n", false, true).instance_variable_get(:@c) )
    assert_equal("print($aw)", AwesomePHP.new("print(aw)", false, true).instance_variable_get(:@c) )
    # method access :
    assert_equal("$awe = $aw->x();\n", AwesomePHP.new("awe = aw.x();\n", false, true).instance_variable_get(:@c) )
    assert_equal("$awe = $aw->x()", AwesomePHP.new("awe = aw.x()", false, true).instance_variable_get(:@c) )
    assert_equal("$awe = $aw->init()->x()->z();\n", AwesomePHP.new("awe = aw.init().x().z();\n", false, true).instance_variable_get(:@c) )
    assert_equal("$awe = $aw->init()->x()->z()", AwesomePHP.new("awe = aw.init().x().z()", false, true).instance_variable_get(:@c) )
    # array :
    assert_equal("$arr = array();\n", AwesomePHP.new("arr = [];\n", false, true).instance_variable_get(:@c) )
    assert_equal("$arr = array()", AwesomePHP.new("arr = []", false, true).instance_variable_get(:@c) )
    # object constructor :
    assert_equal("$aw = new Awesome(\"brilliant!\",2);\n", AwesomePHP.new("aw = Awesome.new(\"brilliant!\",2);\n", false, true).instance_variable_get(:@c) )
    assert_equal("$aw = new Awesome(\"brilliant!\",2)", AwesomePHP.new("aw = Awesome.new(\"brilliant!\",2)", false, true).instance_variable_get(:@c) )
    # variables :
    assert_equal("var $poulet = \"joie\";\n", AwesomePHP.new("@poulet = \"joie\";\n", false, true).instance_variable_get(:@c) )
    assert_equal("$this->poulet;\n", AwesomePHP.new("this.poulet;\n", false, true).instance_variable_get(:@c) )
  end

  def test_multilignes
    # function :
    assert_equal("function __construct(){\npass();\n}\n\n", AwesomePHP.new("def init():\n  pass();\n", false, true).instance_variable_get(:@c) )
    assert_equal("function __construct(){\npass()}\n\n", AwesomePHP.new("def init():\n  pass()", false, true).instance_variable_get(:@c) )
    # IF :
    assert_equal("if ($aw->joie()) {\nprint();\n}\n", AwesomePHP.new("if aw.joie():\n  print();\n", false, true).instance_variable_get(:@c) )
    assert_equal("if ($aw->joie()) {\nprint()}\n", AwesomePHP.new("if aw.joie():\n  print()", false, true).instance_variable_get(:@c) )
    # IF...ELSE :
    assert_equal("if ($poulet->to_i()) {\nprint($awe);\n} else {\nweird();\n}\n", AwesomePHP.new("if poulet.to_i():\n  print(awe);\nelse:\n  weird();", false, true).instance_variable_get(:@c) )    
    assert_equal("if ($poulet->to_i()) {\nprint($awe);\n} else {\nweird();\n}\n", AwesomePHP.new("if poulet.to_i():\n  print(awe);\nelse:\n  weird();", false, true).instance_variable_get(:@c) )    
    assert_equal("if ($poulet->to_i()) {
$aw = new Awesome(\"brilliant!\",2);
$awe = $aw->init()->x()->z();
} else {
weird();
}
", AwesomePHP.new("if poulet.to_i():
  aw = Awesome.new(\"brilliant!\",2);
  awe = aw.init().x().z();
else:
  weird();
", false, true).instance_variable_get(:@c) )    
  end

end