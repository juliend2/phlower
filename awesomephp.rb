require "parser.rb"

code = ''
File.open('input.aw', 'r') do |file|  
  while line = file.gets  
    code << line  
  end  
end



p objects = Parser.new.parse(code)


def ifarg(objet)
  objet.instance_variable_get(:@value)
end

def ifbody(objet)
  puts objet
end

def ifnode(arg, body)
  @f.write("if (")
  yield arg
  @f.write(") {\n")
  yield body
  @f.write("}\n")
  body
end

def classnode(name, body)
  @f.write('class ')
  yield name
  @f.write("{\n\n")
  yield body
  @f.write("}\n\n")
  body
end

def defnode(name, params, body)
  @f.write('function ')
  yield name
  @f.write('(')
  yield params
  @f.write("){\n")
  yield body
  @f.write("}\n\n")
  body
end

def callnode(identifier, arglist, expression={})
  @f.write(identifier+"(")
  yield arglist
  @f.write(");\n")  
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
      if txt.is_a?(Awesome)
        node(txt)
      elsif(txt.instance_of?(Array))
        txt.each {|tx| node(tx)}
      else
        @f.write(txt)
      end
    end
  end
  
  if objet.instance_of?(CallNode)
    callnode(objet.instance_variable_get(:@method), objet.instance_variable_get(:@arguments)) do |txt|
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
    nodenode(objet.instance_variable_get(:@nodes)) do |txt|
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


#<Nodes:0x8fb60 @nodes=[
# #<ClassNode:0x8fbb0 @name="Awesome", @body=#<Nodes:0x8fc14 @nodes=[
#   #<Nodes:0x8fe44 @nodes=[
#     #<Nodes:0x8fea8 @nodes=[
#       #<DefNode:0x8fef8 @name="initialize", @body=#<Nodes:0x8ff5c @nodes=[
#         #<CallNode:0x8ffac @receiver=nil, @arguments=[], @method="pass">
#       ]>, @params=["name"]>
#     ]>, 
#     #<DefNode:0x8fcb4 @name="x", @body=#<Nodes:0x8fd2c @nodes=[
#       #<CallNode:0x8fd7c @receiver=nil, @arguments=[
#         #<LiteralNode:0x8fdf4 @value=2>
#       ], @method="return">
#     ]>, @params=[]>
#   ]>
# ]>>, 
# #<IfNode:0x8f804 @condition=#<LiteralNode:0x8fb10 @value=true>, @body=#<Nodes:0x8f958 @nodes=[
#   #<SetLocalNode:0x8f9a8 @name="aw", @value=#<CallNode:0x8f9f8 @receiver=#<GetConstantNode:0x8fac0 @name="Awesome">, @arguments=[
#     #<LiteralNode:0x8fa70 @value="brilliant!">
#   ], @method="new">>
# ]>, @else_body=#<Nodes:0x8f868 @nodes=[
#   #<CallNode:0x8f8b8 @receiver=nil, @arguments=[], @method="weird">
# ]>>
#]>
