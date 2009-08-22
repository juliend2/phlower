require "parser.rb"

# 
# Synopsis : ruby awesomephp.rb input.aw compiled.php
# input.aw = awesome input file
# compiled.php = php output file
# 

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

def callnode(identifier, arglist, receiver)
  # new Class(args)
  if identifier=='new' && receiver!='' && receiver.instance_of?(GetConstantNode)
    @c << "$"+identifier+" = new "
    yield receiver
    @c << "("
    arglist.each_with_index do |arg, count|
      yield arg
      if count<(arglist.length-1)
        @c << ","
      end
    end
    @c << ");\n"
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
      @c << "$"+receiver.instance_variable_get(:@method).to_s+"->"+identifier+"("
      arglist.each_with_index do |arg, count|
        yield arg
        if count<(arglist.length-1)
          @c << ","
        end
      end
      @c << ");\n"
    end
  else
    @c << identifier+"("
    arglist.each_with_index do |arg, count|
      yield arg
      if count<(arglist.length-1)
        @c << ","
      end
    end
    @c << ");\n"
  end
end

def setlocalnode(name, value)
  @c << "$"+name+' = '
  yield value
  if !value.instance_of?(CallNode)  
    @c << ";\n"
  end
end

def getconstantnode(name)
  @c << name
end

def nodenode(nod)
  yield nod
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
        @c << txt
      end
    end
  end
  
  # if true:
  if objet.instance_of?(IfNode)
    ifnode(objet.instance_variable_get(:@condition), 
      objet.instance_variable_get(:@body), 
      objet.instance_variable_get(:@else_body)) do |txt|
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
    classnode(objet.instance_variable_get(:@name), 
    objet.instance_variable_get(:@body)) do |txt|
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
    defnode(objet.instance_variable_get(:@name), 
    objet.instance_variable_get(:@params), 
    objet.instance_variable_get(:@body)) do |txt|
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
    callnode(objet.instance_variable_get(:@method), 
    objet.instance_variable_get(:@arguments), 
    objet.instance_variable_get(:@receiver)) do |txt|
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
    setlocalnode(objet.instance_variable_get(:@name), 
    objet.instance_variable_get(:@value)) do |txt|
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
    nodenode(objet.instance_variable_get(:@nodes)) do |txt|
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
    literalnode(objet.instance_variable_get(:@value)) do |txt|
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
  def initialize(inputfile, outputfile=false, isstring=false)
    @input = inputfile
    @output = outputfile
    @isstring = isstring
    
    if @isstring==true && @output==false
      puts
      puts 'from string'
      @c = ''
      # input
      code = @input

      p objects = Parser.new.parse(code)

      # output
      returned = ''
      if objects.instance_of?(Nodes)
        objarray = objects.instance_variable_get(:@nodes)
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
        objarray = objects.instance_variable_get(:@nodes)
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

#<Nodes:0x80ef8 @nodes=[
# #<Nodes:0x81cf4 @nodes=[
#   #<DefNode:0x81d44 @body=#<Nodes:0x81da8 @nodes=[
#     #<Nodes:0x81e0c @nodes=[
#       #<CallNode:0x81e5c @receiver=nil, @arguments=[
#         #<LiteralNode:0x81ed4 @value="joie">
#       ], @method="echo">
#     ]>
#   ]>, @name="pass", @params=[]>, 
#   #<ClassNode:0x81538 @body=#<Nodes:0x8159c @nodes=[
#     #<Nodes:0x817cc @nodes=[
#       #<Nodes:0x81ac4 @nodes=[
#         #<Nodes:0x81b28 @nodes=[
#           #<DefNode:0x81b78 @body=#<Nodes:0x81bdc @nodes=[
#             #<CallNode:0x81c2c @receiver=nil, @arguments=[], @method="pass">
#           ]>, @name="init", @params=[]>
#         ]>, #<DefNode:0x8186c @body=#<Nodes:0x818e4 @nodes=[
#           #<CallNode:0x81934 @receiver=nil, @arguments=[
#             #<CallNode:0x819ac @receiver=#<LiteralNode:0x81a74 @value=2>, @arguments=[
#               #<LiteralNode:0x81a10 @value=2>
#             ], @method="+">
#           ], @method="return">
#         ]>, @name="x", @params=[]>
#       ]>, 
#       #<DefNode:0x8163c @body=#<Nodes:0x816b4 @nodes=[
#         #<CallNode:0x81704 @receiver=nil, @arguments=[
#           #<LiteralNode:0x8177c @value="poulet">
#         ], @method="print">
#       ]>, @name="z", @params=[]>
#     ]>
#   ]>, @name="Awesome">, 
#   #<IfNode:0x80fac @body=#<Nodes:0x8127c @nodes=[
#     #<SetLocalNode:0x812cc @value=#<CallNode:0x8131c @receiver=#<GetConstantNode:0x8145c @name="Awesome">, @arguments=[
#       #<LiteralNode:0x8140c @value="brilliant!">, 
#       #<LiteralNode:0x81394 @value=2>
#     ], @method="new">, @name="aw">, 
#     #<SetLocalNode:0x8113c @value=#<CallNode:0x8118c @receiver=#<CallNode:0x8122c @receiver=nil, @arguments=[], @method="aw">, @arguments=[], @method="x">, @name="awe">
#   ]>, @condition=#<LiteralNode:0x814ac @value=true>, @else_body=#<Nodes:0x81010 @nodes=[
#     #<CallNode:0x81060 @receiver=nil, @arguments=[], @method="weird">
#   ]>>
# ]>
#]>
