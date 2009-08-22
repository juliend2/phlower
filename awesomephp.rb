require "parser.rb"

# 
# Synopsis : ruby awesomephp.rb input.aw compiled.php
# input.aw = awesome input file
# compiled.php = php output file
# 

def ifarg(objet)
  objet.instance_variable_get(:@value)
end

def ifbody(objet)
  puts objet
end

def ifnode(arg, body)
  @c << "if ("
  yield arg
  @c << ") {\n"
  yield body
  @c << "}\n"
  body
end

def classnode(name, body)
  @c << 'class '
  yield name
  @c << "{\n\n"
  yield body
  @c << "}\n\n"
  body
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
  body
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
      @c << "("
      yield receiver
      @c << "+"
      yield arglist
      @c << ")"
    elsif identifier=='-'
      @c << "("
      yield receiver
      @c << "-"
      yield arglist
      @c << ")"
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
  if !value.instance_of?(CallNode)
    yield value
    @c << ";\n"
  else
    if value.instance_variable_get(:@method).to_s == 'new'
      @c << "new "+(value.instance_variable_get(:@receiver)).instance_variable_get(:@name).to_s+"("
      # yield value.instance_variable_get(:@arguments)
      len = value.instance_variable_get(:@arguments).length
      (value.instance_variable_get(:@arguments)).each_with_index do |arg, count|
        yield arg
        if count<(len-1)
          @c << ","
        end
      end
      @c << ");\n"
    end
  end
end

def getconstantnode(name)
  @c << name
end

def nodenode(nod)
  yield nod
end

def literalnode(node)
  # puts node.class
  if node.instance_of?(String)
    @c << '"'
    yield node
    @c << '"'
  else
    yield node
  end
  
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
        @c << txt
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
        @c << txt
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
        @c << txt
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
        @c << txt
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
        @c << txt
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
      puts 'from string'
      puts
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
