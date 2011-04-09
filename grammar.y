class Parser

# Declare tokens produced by the lexer
token IF ELSE
token DEF
token CLASS
token NEWLINE
token NUMBER
token STRING
token TRUE FALSE NIL
token IDENTIFIER
token CONSTANT
token INDENT DEDENT

# racc -o parser.rb grammar.y   <-- to regenerate the parser.rb

rule
  # All rules are declared in this format:
  #
  #   RuleName:
  #     OtherRule TOKEN AnotherRule    { code to run when this matches }
  #   | OtherRule                      { ... }
  #   ;
  #
  # In the code section ({...} on the right):
  # - Assign to "result" the value returned by the rule.
  # - Use val[index of expression] to reference expressions on the left.
  

  
  
  # All parsing will end in this rule, being the trunk of the AST.
  Root:
    /* nothing */                      { result = Nodes.new([]) }
  | Expressions                        { result = val[0] }
  ;
  
  # Any list of expressions, class or method body.
  Expressions:
    Expression                         { result = Nodes.new(val) }
  | Expressions Terminator Expression  { result = val[0] << val[2] }
    # To ignore trailing line breaks
  | Expressions Terminator             { result = Nodes.new([val[0]]) }
  ;

  # All types of expressions in our language
  Expression:
    Literal
  | Call
  | Var
  | Constant
  | Assign
  | Def
  | Class
  | If
  | Array
  ;
  
  # All tokens that can terminate an expression
  Terminator:
    NEWLINE
  | ";"
  ;
  
  Literal:
    NUMBER                        { result = LiteralNode.new(val[0]) }
  | STRING                        { result = LiteralNode.new(val[0]) }
  | TRUE                          { result = LiteralNode.new(true) }
  | FALSE                         { result = LiteralNode.new(false) }
  | NIL                           { result = LiteralNode.new(nil) }
  ;
  
  # operateurs mathematiques :
  BinaryOperator: 
    "+" 
  | "-" 
  | "*"
  | "/"
  | "%"
  ; 
  
  Var:
  # variable :
  IDENTIFIER                    { result = VarNode.new(val[0]) }
  ;
  
  # A method call
  Call:
   # method(arguments)
   IDENTIFIER "(" ArgList ")"    { result = CallNode.new(nil, val[0], val[2], false) }
    # receiver.method
  | Expression "." IDENTIFIER     { result = CallNode.new(val[0], val[2], false) }
    # receiver.method(arguments)
  | Expression "."
      IDENTIFIER "(" ArgList ")"  { result = CallNode.new(val[0], val[2], val[4], false) }
  | Expression BinaryOperator Expression  { result = CallNode.new(val[0], val[1], [val[2]], false) } 
  # VERSION WITH ; AT THE END
  | IDENTIFIER "(" ArgList ")" Terminator    { result = CallNode.new(nil, val[0], val[2], true) }
    # receiver.method
  | Expression "." IDENTIFIER Terminator   { result = CallNode.new(val[0], val[2], nil, true) }
    # receiver.method(arguments)
  | Expression "."
      IDENTIFIER "(" ArgList ")" Terminator  { result = CallNode.new(val[0], val[2], val[4], true) }
  | Expression BinaryOperator Expression Terminator  { result = CallNode.new(val[0], val[1], [val[2]], true) }
  ;
  
  Array:
  |  "[" ArgList "]"               { result = ArrayNode.new(val[1]) }
  ;
  
  ArgList:
    /* nothing */                 { result = [] }
  | Expression                    { result = val }
  | ArgList "," Expression        { result = val[0] << val[2] }
  ;
  
  Constant:
    CONSTANT                      { result = GetConstantNode.new(val[0]) }
  ;
  
  # Assignation to variables or constants
  Assign:
    IDENTIFIER "=" Expression     { result = SetLocalNode.new(val[0], val[2], false) }
  | IDENTIFIER "=" Expression Terminator    { result = SetLocalNode.new(val[0], val[2], true) }
  | CONSTANT "=" Expression       { result = SetConstantNode.new(val[0], val[2]) }
  ;
  
    
  # Method definition
  Def:
    DEF IDENTIFIER Block          { result = DefNode.new(val[1], [], val[2]) }
  | DEF IDENTIFIER
      "(" ParamList ")" Block     { result = DefNode.new(val[1], val[3], val[5]) }
  ;

  ParamList:
    /* nothing */                 { result = [] }
  | IDENTIFIER                    { result = val }
  | ParamList "," IDENTIFIER      { result = val[0] << val[2] }
  ;
  
  # Class definition
  Class:
    CLASS CONSTANT Block          { result = ClassNode.new(val[1], val[2]) }
  ;
  
  # if and if-else block
  If:
    IF Expression Block
    ELSE Block                    { result = IfNode.new(val[1], val[2], val[4]) }
  | IF Expression Block           { result = IfNode.new(val[1], val[2]) }
  ;
  
  # A block of indented code. You see here that all the hard work was done
  # by the lexer.
  Block:
    # INDENT Expressions DEDENT     { result = val[1] }
  # If you don't like indentation you could replace the previous rule with
  # the following one do seperate blocks w/ "{" ... "}".
  # (You'll need remove the indentation magic section in the lexer too)
    "{" Expressions "}"           { result = val[1] }
  ;
end

---- header
  require "lexer"
  require "nodes"

---- inner
  def parse(code, show_tokens=false)
    @tokens = Lexer.new.tokenize(code)
    puts @tokens.inspect if show_tokens
    do_parse
  end
  
  def next_token
    @tokens.shift
  end
