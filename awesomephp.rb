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

def callnode(identifier, arglist, expression="")
  if identifier=='new' && expression!='' && expression.instance_of?(GetConstantNode)
    @f.write("$"+identifier+" = new ")
    yield expression
    @f.write("(")
    yield arglist
    @f.write(");\n")
  elsif expression!=''
    @f.write("$"+expression.to_s+"->"+identifier+"(")
    yield arglist
    @f.write(");\n")
  else
    @f.write(identifier+"(")
    yield arglist
    @f.write(");\n")
  end
end

def setlocalnode(name, value)
  if value.instance_of?(CallNode)
    yield value
  else
    @f.write("$"+name+' = ')
    
    @f.write(";\n")
  end
end

def getconstantnode(name)
  @f.write(name)
end

def nodenode(nod)
  yield nod
end

def literalnode(node)
  yield node
end

def node(objet)
  
  if objet.instance_of?(CallNode)
    puts objet.inspect
    puts
  end
  
  if objet.instance_of?(GetConstantNode)
    getconstantnode(objet.instance_variable_get(:@name)) do |txt|
      if txt.is_a?(Awesome)
        node(txt)
      elsif(txt.instance_of?(Array))
        txt.each {|tx| node(tx)}
      else
        @f.write(txt)
      end
    end
  end
  
  # if true:
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
  
  # class Name:
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
  
  # def methode:
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
  
  # objet.method(args)
  if objet.instance_of?(CallNode)
    callnode(objet.instance_variable_get(:@method), objet.instance_variable_get(:@arguments), objet.instance_variable_get(:@receiver)) do |txt|
      if txt.is_a?(Awesome)
        node(txt)
      elsif(txt.instance_of?(Array))
        txt.each {|tx| node(tx)}
      else
        @f.write(txt)
      end
    end
  end
  
  # var = value
  if objet.instance_of?(SetLocalNode)
    setlocalnode(objet.instance_variable_get(:@name), objet.instance_variable_get(:@value)) do |txt|
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
