require "parser.rb"

code = <<-EOS
class Awesome:
  def initialize(name):
    pass
  
  def x:
    2

if true:
  aw = Awesome.new("brilliant!")
else:
  weird
EOS



p objects = Parser.new.parse(code)


def ifarg(objet)
  objet.instance_variable_get(:@value)
end

def ifbody(objet)
  puts objet
end

def ifnode(arg, body)
  # puts "if ("
  @f.write('if (')
  yield arg
  # puts ") {"
  @f.write(') {')
  yield body
  # puts "}"
  @f.write('}')
  body
end

def classnode(name, body)
  # puts "class "
  @f.write('class ')
  yield name
  # puts "{"
  @f.write('{')
  yield body
  # puts "}"
  @f.write('}')
  body
end

def defnode(name, params, body)
  # puts "function "
  @f.write('function ')
  yield name
  @f.write('(')
  yield params
  @f.write('){')
  yield body
  # puts "}"
  @f.write('}')
  body
end

def nodenode(nod)
  yield nod
end

def literalnode(node)
  yield node
end

def node(objet)
  
  if objet.instance_of?(IfNode)
    ifnode(objet.instance_variable_get(:@condition), objet.instance_variable_get(:@body)) do |txt|
      # puts txt
      if txt.is_a?(Awesome)
        node(txt)
      elsif(txt.instance_of?(Array))
        txt.each {|tx| node(tx)}
      else
        @f.write(txt)
      end
    end
  end
  
  if objet.instance_of?(ClassNode)
    classnode(objet.instance_variable_get(:@name), objet.instance_variable_get(:@body)) do |txt|
      # puts txt.is_a?(Awesome)
      if txt.is_a?(Awesome)
        node(txt)
      elsif(txt.instance_of?(Array))
        txt.each {|tx| node(tx)}
      else
        @f.write(txt)
      end
    end
  end
  
  if objet.instance_of?(DefNode)
    defnode(objet.instance_variable_get(:@name), objet.instance_variable_get(:@params), objet.instance_variable_get(:@body)) do |txt|
      # puts txt.to_s + " : " + txt.class.to_s + " " + txt.length.to_s unless 
      if txt.is_a?(Awesome)
        node(txt)
      elsif(txt.instance_of?(Array))
        txt.each {|tx| node(tx)}
      else
        @f.write(txt)
      end
    end
  end
  
  if objet.instance_of?(Nodes)
    # yield node(objet.instance_variable_get(:@nodes)) if block_given?
    nodenode(objet.instance_variable_get(:@nodes)) do |txt|
      # puts txt
      if txt.is_a?(Awesome)
        node(txt)
      elsif(txt.instance_of?(Array))
        txt.each {|tx| node(tx)}
      else
        @f.write(txt)
      end
    end
  end
  
  if objet.instance_of?(LiteralNode)
    literalnode(objet.instance_variable_get(:@value)) do |txt|
      if txt.is_a?(Awesome)
        node(txt)
      elsif(txt.instance_of?(Array))
        txt.each {|tx| node(tx)}
      else
        @f.write(txt)
      end
    end
  end
  
  if objet.instance_of?(String)
    @f.write('"' + objet + '"')
  end
end


@f = File.open("compiled.txt", "w")
if objects.instance_of?(Nodes)
  objarray = objects.instance_variable_get(:@nodes)
  objarray.each do |object|
    @f.write( node(object))
  end
end
@f.close()

#<Nodes:0x8ff34 @nodes=[
# #<ClassNode:0x8ff84 @body=#<Nodes:0x8ffe8 @nodes=[
#   #<Nodes:0x901a0 @nodes=[
#     #<Nodes:0x90204 @nodes=[
#       #<DefNode:0x90254 @body=#<Nodes:0x902b8 @nodes=[
#         #<CallNode:0x9031c @arguments=[], @method="pass", @receiver=nil>
#       ]>, @params=["name"], @name="initialize">
#     ]>, 
#     #<DefNode:0x90088 @body=#<Nodes:0x90100 @nodes=[
#       #<LiteralNode:0x90150 @value=3>
#     ]>, @params=[], @name="x">
#   ]>
# ]>, @name="Awesome">, 
# #<IfNode:0x8fc00 @body=#<Nodes:0x8fd2c @nodes=[
#   #<SetLocalNode:0x8fd7c @name="aw", @value=#<CallNode:0x8fdcc @arguments=[
#     #<LiteralNode:0x8fe44 @value="brilliant!">
#   ], @method="new", @receiver=#<GetConstantNode:0x8fe94 @name="Awesome">>>
# ]>, @condition=#<LiteralNode:0x8fee4 @value=true>, @else_body=#<Nodes:0x8fc64 @nodes=[
#   #<CallNode:0x8fcc8 @arguments=[], @method="weird", @receiver=nil>
# ]>>
# ]>
