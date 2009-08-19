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



objects = Parser.new.parse(code)


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

def defnode(name, body)
  # puts "function "
  @f.write('function ')
  yield name
  # puts "(){"
  @f.write('(){')
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
  # puts objet.class
  
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
    defnode(objet.instance_variable_get(:@name), objet.instance_variable_get(:@body)) do |txt|
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
  
  # if objet.instance_of?(String)
  #     yield objet if block_given?
  #   end
end


@f = File.open("compiled.txt", "w")
if objects.instance_of?(Nodes)
  objarray = objects.instance_variable_get(:@nodes)
  objarray.each do |object|
    @f.write( node(object))
  end
end
@f.close()


# <Nodes @nodes=[
#   <ClassNode @name="Awesome", @body=<Nodes @nodes=[
#     <Nodes @nodes=[
#       <Nodes @nodes=[
#         <DefNode @name="initialize", @params=["name"], @body=<Nodes @nodes=[
#           <CallNode @method="pass">
#         ]>>
#       ]>,
#       <DefNode @name="x", @body=<Nodes @nodes=[
#         <LiteralNode @value=2>
#       ]>>
#     ]>
#   ]>>,
#   <IfNode @condition=<LiteralNode @value=true>, @body=<Nodes @nodes=[
#     <SetLocalNode @name="aw",
#                   @value=<CallNode @method="new",
#                                    @arguments=[<LiteralNode @value="brilliant!">],
#                                    @receiver=<GetConstantNode @name="Awesome">>>
#   ]>, @else_body=<Nodes @nodes=[
#     <CallNode @method="weird">
#   ]>>
# ]>


# <Nodes:0x933b4 @nodes=[
#   <ClassNode:0x93404 @name="Awesome", @body=#<Nodes:0x93468 @nodes=[
#     <Nodes:0x93620 @nodes=[
#       <Nodes:0x93684 @nodes=[
#         <DefNode:0x936d4 @name="initialize", @body=#<Nodes:0x93738 @nodes=[
#           <CallNode:0x9379c @receiver=nil, @arguments=[], @method="pass">
#         ]>, @params=["name"]>
#       ]>, 
#       <DefNode:0x93508 @name="x", @body=#<Nodes:0x93580 @nodes=[
#         <LiteralNode:0x935d0 @value=2>
#       ]>, @params=[]>
#     ]>
#   ]>>, 
#   <IfNode:0x93080 @else_body=#<Nodes:0x930e4 @nodes=[
#     <CallNode:0x93148 @receiver=nil, @arguments=[], @method="weird">
#   ]>, @body=#<Nodes:0x931ac @nodes=[
#     <SetLocalNode:0x931fc @name="aw", @value=#<CallNode:0x9324c @receiver=#<GetConstantNode:0x93314 @name="Awesome">, @arguments=[
#       <LiteralNode:0x932c4 @value="brilliant!">
#     ], @method="new">>
#   ]>, @condition=#<LiteralNode:0x93364 @value=true>>
# ]>