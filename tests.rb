require 'phlower.rb'
require "test/unit"

class TestAwesomePHP < Test::Unit::TestCase
  
  def test_singleline
    # print :
    assert_equal("$ho->print(\"joie\");\n", AwesomePHP.new("ho.print(\"joie\");\n", false, true).c )
    assert_equal("$ho->print(\"joie\")", AwesomePHP.new("ho.print(\"joie\")", false, true).c )
    assert_equal("print(\"joie\");\n", AwesomePHP.new("print(\"joie\");\n", false, true).c )
    assert_equal("print(\"joie\")", AwesomePHP.new("print(\"joie\")", false, true).c )
    assert_equal("print($aw);\n", AwesomePHP.new("print(aw);\n", false, true).c )
    assert_equal("print($aw)", AwesomePHP.new("print(aw)", false, true).c )
    # method access :
    assert_equal("$awe = $aw->x();\n", AwesomePHP.new("awe = aw.x();\n", false, true).c )
    assert_equal("$awe = $aw->x()", AwesomePHP.new("awe = aw.x()", false, true).c )
    assert_equal("$awe = $aw->init()->x()->z();\n", AwesomePHP.new("awe = aw.init().x().z();\n", false, true).c )
    assert_equal("$awe = $aw->init()->x()->z()", AwesomePHP.new("awe = aw.init().x().z()", false, true).c )
    # array :
    assert_equal("$arr = array();\n", AwesomePHP.new("arr = [];\n", false, true).c )
    assert_equal("$arr = array()", AwesomePHP.new("arr = []", false, true).c )
    # object constructor :
    assert_equal("$aw = new Awesome(\"brilliant!\",2);\n", AwesomePHP.new("aw = Awesome.new(\"brilliant!\",2);\n", false, true).c )
    assert_equal("$aw = new Awesome(\"brilliant!\",2)", AwesomePHP.new("aw = Awesome.new(\"brilliant!\",2)", false, true).c )
    # variables :
    assert_equal("var $poulet = \"joie\";\n", AwesomePHP.new("@poulet = \"joie\";\n", false, true).c )
    assert_equal("$this->poulet;\n", AwesomePHP.new("this.poulet;\n", false, true).c )
  end

  def test_multilignes
    # IF :
    assert_equal("if ($aw->joie()) {\nprint();\n}\n", AwesomePHP.new("if aw.joie(){\n  print();}\n", false, true).c )
    assert_equal("if ($aw->joie()) {\nprint()}\n", AwesomePHP.new("if aw.joie(){\n  print()}", false, true).c )
    # function :
    assert_equal("function __construct(){\npass();\n}\n\n", AwesomePHP.new("def init(){ pass();}", false, true).c )
    assert_equal("function __construct(){\npass()}\n\n", AwesomePHP.new("def init(){\n  pass()}", false, true).c )
    # IF...ELSE :
    assert_equal("if ($poulet->to_i()) {\nprint($awe);\n} else {\nweird();\n}\n", AwesomePHP.new("if poulet.to_i(){\n  print(awe);}else{\n  weird();}", false, true).c )    
    assert_equal("if ($volaille->to_i()) {\nprint($awe);\n} else {\nweird();\n}\n", AwesomePHP.new("if volaille.to_i(){\n  print(awe);}else{\n  weird();}", false, true).c )    
    assert_equal("if ($dindon->to_a()) {
$aw = new Awesome(\"brilliant!\",2);
} else {
weird();
}
", AwesomePHP.new("if dindon.to_a(){
  aw = Awesome.new(\"brilliant!\",2);
  awe = aw.init().x().z();
}else{
  weird();
}", false, true).c )    
  end

end
