require "parser.rb"

# 
# Synopsis : ruby awesomephp.rb input.aw compiled.php
# input.aw = awesome input file
# compiled.php = php output file
# 

# can be : ext for external, arg for argument (if or method), body for body of a method/block :

def ifnode(arg, body, elsebody)
  @c << "if ("
  yield arg
  @c << ") {\n"
  yield body
  if !(elsebody.nil?)
    @c << "} else {\n"
    yield elsebody
    @c << "}\n"
  else
    @c << "}\n"
  end
end

def classnode(name, body)
  @c << 'class '
  yield name
  @c << "{\n\n"
  yield body
  @c << "}\n\n"
end

def defnode(name, params, body)
  @c << 'function '
  if name=='init'
    @c << '__construct'
  else
    @c << name
  end
  @c << '('
  yield params
  @c << "){\n"
  yield body
  @c << "}\n\n"
end

def callnode(identifier, arglist, receiver, is_end)
  
  # new Class(args)
  if identifier=='new' && receiver!='' && receiver.instance_of?(GetConstantNode)
    @c << "new "
    yield receiver
    @c << "("
    arglist.each_with_index do |arg, count|
      yield arg
      if count<(arglist.length-1)
        @c << ","
      end
    end
    @c << ")"
    if is_end
      @c << ";\n"
    end
  # obj.method(args)
  # OR
  # 2+2
  elsif !(receiver.nil?)
    if identifier=='+'
      yield receiver
      @c << " + "
      yield arglist
    elsif identifier=='-'
      yield receiver
      @c << " - "
      yield arglist
    elsif identifier=='*'
      yield receiver
      @c << " * "
      yield arglist
    elsif identifier=='/'
      yield receiver
      @c << " / "
      yield arglist
    elsif identifier=='%'
      yield receiver
      @c << " % "
      yield arglist
    else
      yield receiver,receiver.class
      if arglist
        @c << "->"+identifier+"("
        arglist.each_with_index do |arg, count|
          yield arg
          if count<(arglist.length-1)
            @c << ","
          end
        end
        @c << ")"
      else
        @c << "->"+identifier
      end
      
      if is_end
        @c << ";\n"
      end
    end
  # function(args)
  else
    @c << identifier+"("
    arglist.each_with_index do |arg, count|
      yield arg
      if count<(arglist.length-1)
        @c << ","
      end
    end
    @c << ")"
    if is_end
      @c << ";\n"
    end
  end
end

def setlocalnode(name, value, is_end)
  if name[0,1] == '@'
    @c << "var $"+name[1,name.length]+' = '
  else
    @c << "$"+name+' = '
  end
  
  yield value
  # if !value.instance_of?(CallNode)  
  if is_end
    @c << ";\n"
  end
  # end
end

def arraynode(values)
  @c << "array("
  values.each_with_index do |arg, count|
    yield arg
    if count<(values.length-1)
      @c << ","
    end
  end
  @c << ")"
end

def getconstantnode(name)
  @c << name
end

def nodenode(nod)
  yield nod
end

def varnode(node)
  @c << "$"
  yield node
end

def literalnode(node)
  if node.instance_of?(String)
    @c << '"'
    yield node
    @c << '"'
  else
    yield node
  end
end

def node(objet)

  if objet.instance_of?(SetLocalNode)
    # puts objet.inspect
    # puts
  end
  
  if objet.instance_of?(ArrayNode)
    arraynode(objet.values) do |txt|
      if txt.is_a?(Awesome)
        node(txt)
      elsif(txt.instance_of?(Array))
        txt.each {|tx| node(tx)}
      else
        @c << txt unless txt.nil?
      end
    end
  end
  
  if objet.instance_of?(GetConstantNode)
    getconstantnode(objet.name) do |txt|
      if txt.is_a?(Awesome)
        node(txt)
      elsif(txt.instance_of?(Array))
        txt.each {|tx| node(tx)}
      else
        @c << txt
      end
    end
  end
  
  # if true:
  if objet.instance_of?(IfNode)
    ifnode(objet.condition, objet.body, objet.else_body) do |txt|
      if txt.is_a?(Awesome)
        node(txt)
      elsif(txt.instance_of?(Array))
        txt.each {|tx| node(tx)}
      else
        @c << txt
      end
    end
  end
  
  # class Name:
  if objet.instance_of?(ClassNode)
    classnode(objet.name, objet.body) do |txt|
      if txt.is_a?(Awesome)
        node(txt)
      elsif(txt.instance_of?(Array))
        txt.each {|tx| node(tx)}
      else
        @c << txt
      end
    end
  end
  
  # def methode:
  if objet.instance_of?(DefNode)
    defnode(objet.name, objet.params, objet.body) do |txt|
      if txt.is_a?(Awesome)
        node(txt)
      elsif(txt.instance_of?(Array))
        txt.each {|tx| node(tx)}
      else
        @c << txt
      end
    end
  end
  
  # objet.method(args)
  if objet.instance_of?(CallNode)
    callnode(objet.method, objet.arguments, objet.receiver, objet.is_end) do |txt, type|
      if txt.is_a?(Awesome)
        node(txt)
      elsif(txt.instance_of?(Array))
        txt.each {|tx,typ| node(tx)}
      else
        @c << txt unless txt.nil?
      end
    end
  end
  
  # variable
  if objet.instance_of?(VarNode)
    varnode(objet.name) do |txt|
      if txt.is_a?(Awesome)
        node(txt)
      elsif(txt.instance_of?(Array))
        txt.each {|tx| node(tx)}
      else
        @c << txt
      end
    end
  end
  
  # var = value
  if objet.instance_of?(SetLocalNode)
    setlocalnode(objet.name, objet.value, objet.is_end) do |txt|
      if txt.is_a?(Awesome)
        node(txt)
      elsif(txt.instance_of?(Array))
        txt.each {|tx| node(tx)}
      else
        @c << txt
      end
    end
  end
  
  if objet.instance_of?(Nodes)
    nodenode(objet.nodes) do |txt|
      if txt.is_a?(Awesome)
        node(txt)
      elsif(txt.instance_of?(Array))
        txt.each {|tx| node(tx)}
      else
        @c << txt
      end
    end
  end
  
  if objet.instance_of?(LiteralNode)
    literalnode(objet.value) do |txt|
      if txt.is_a?(Awesome)
        node(txt)
      elsif(txt.instance_of?(Array))
        txt.each {|tx| node(tx)}
      else
        @c << txt.to_s
      end
    end
  end
  
  if objet.instance_of?(String)
    @c << '"' + objet + '"'
  end
end


class AwesomePHP
  attr_accessor :c
  def initialize(inputfile, outputfile=false, isstring=false)
    @input = inputfile
    @output = outputfile
    @isstring = isstring
    
    if @isstring==true && @output==false
      @c = ''
      # input
      code = @input

      p objects = Parser.new.parse(code)

      # output
      returned = ''
      if objects.instance_of?(Nodes)
        objarray = objects.nodes
        objarray.each do |object|
          returned << node(object)  unless node(object).nil?
        end
      end
      return @c
    else
      # input
      @c = ''
      code = ''
      File.open(@input, 'r') do |file|  
        while line = file.gets  
          code << line unless line.nil?
        end  
      end

      p objects = Parser.new.parse(code)  unless code.nil?

      # output
      @c << "<?php\n\n"
      if objects.instance_of?(Nodes)
        objarray = objects.nodes
        objarray.each do |object|
          @c << node(object)  unless node(object).nil?
        end
      end
      @f = File.open(@output, "w")
      @f.write(@c)
      @f.close() 
    end
  end
  
end


# Call the parser if we called this file by the command line :
if ARGV[0] && ARGV[1]
  parsing = AwesomePHP.new(ARGV[0], ARGV[1])
end

#<Nodes:0x8014c @nodes=[
# #<Nodes:0x811f0 @nodes=[
#   #<DefNode:0x81240 @name="pass", @params=[], @body=#<Nodes:0x812a4 @nodes=[
#     #<Nodes:0x81308 @nodes=[
#       #<CallNode:0x81358 @method="echo", @receiver=nil, @arguments=[
#         #<LiteralNode:0x813d0 @value="joie">
#       ]>
#     ]>
#   ]>>, #<ClassNode:0x809e4 @name="Awesome", @body=#<Nodes:0x80a48 @nodes=[
#     #<Nodes:0x80ca0 @nodes=[
#       #<Nodes:0x80fc0 @nodes=[
#         #<Nodes:0x81024 @nodes=[
#           #<DefNode:0x81074 @name="init", @params=[], @body=#<Nodes:0x810d8 @nodes=[
#             #<CallNode:0x81128 @method="pass", @receiver=nil, @arguments=[]>
#           ]>>
#         ]>, 
#         #<DefNode:0x80d40 @name="x", @params=[], @body=#<Nodes:0x80da4 @nodes=[
#           #<CallNode:0x80df4 @method="return", @receiver=nil, @arguments=[
#             #<CallNode:0x80e6c @method="+", @receiver=#<LiteralNode:0x80f34 @value=2>, @arguments=[
#               #<LiteralNode:0x80ed0 @value=2>
#             ]>
#           ]>
#         ]>>
#       ]>, 
#       #<DefNode:0x80ae8 @name="z", @params=[], @body=#<Nodes:0x80b4c @nodes=[
#         #<CallNode:0x80b9c @method="print", @receiver=nil, @arguments=[
#           #<LiteralNode:0x80c14 @value="poulet">
#         ]>
#       ]>>
#     ]>
#   ]>>, 
#   #<SetLocalNode:0x80908 @value=#<LiteralNode:0x80958 @value=true>, @name="poulet">, 
#   #<IfNode:0x80200 @else_body=#<Nodes:0x80264 @nodes=[
#     #<CallNode:0x802b4 @method="weird", @receiver=nil, @arguments=[]>
#   ]>, @body=#<Nodes:0x8064c @nodes=[
#     #<SetLocalNode:0x8069c @value=#<CallNode:0x806ec @method="new", @receiver=#<GetConstantNode:0x8082c @name="Awesome">, @arguments=[
#       #<LiteralNode:0x807dc @value="brilliant!">, 
#       #<LiteralNode:0x80764 @value=2>
#     ]>, @name="aw">, 
#     #<SetLocalNode:0x80494 @value=#<CallNode:0x804e4 @method="z", @receiver=#<CallNode:0x80570 @method="x", @receiver=#<VarNode:0x805fc @name="aw">, @arguments=[]>, @arguments=[]>, @name="awe">, 
#     #<CallNode:0x80390 @method="print", @receiver=nil, @arguments=[
#       #<VarNode:0x80408 @name="awe">
#     ]>
#   ]>, @condition=#<VarNode:0x8087c @name="poulet">>
# ]>
#]>

