require "parser.rb"
require "test/unit"


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
  if name=='init'
    @f.write('__construct')
  else
    @f.write(name)
  end
  @f.write('(')
  yield params
  @f.write("){\n")
  yield body
  @f.write("}\n\n")
  body
end

def callnode(identifier, arglist, receiver)
  # new Class(args)
  if identifier=='new' && receiver!='' && receiver.instance_of?(GetConstantNode)
    @f.write("$"+identifier+" = new ")
    yield receiver
    @f.write("(")
    arglist.each_with_index do |arg, count|
      yield arg
      if count<(arglist.length-1)
        @f.write(",")
      end
    end
    @f.write(");\n")
  # obj.method(args)
  # OR
  # 2+2
  elsif !(receiver.nil?)
    if identifier=='+'
      @f.write("(")
      yield receiver
      @f.write("+")
      yield arglist
      @f.write(")")
    elsif identifier=='-'
      @f.write("(")
      yield receiver
      @f.write("-")
      yield arglist
      @f.write(")")
    else
      @f.write("$"+receiver.instance_variable_get(:@method).to_s+"->"+identifier+"(")
      arglist.each_with_index do |arg, count|
        yield arg
        if count<(arglist.length-1)
          @f.write(",")
        end
      end
      @f.write(");\n")
    end
  else
    @f.write(identifier+"(")
    arglist.each_with_index do |arg, count|
      yield arg
      if count<(arglist.length-1)
        @f.write(",")
      end
    end
    @f.write(");\n")
  end
end

def setlocalnode(name, value)
  @f.write("$"+name+' = ')
  if !value.instance_of?(CallNode)
    yield value
    @f.write(";\n")
  else
    if value.instance_variable_get(:@method).to_s == 'new'
      @f.write("new "+(value.instance_variable_get(:@receiver)).instance_variable_get(:@name).to_s+"(")
      # yield value.instance_variable_get(:@arguments)
      len = value.instance_variable_get(:@arguments).length
      (value.instance_variable_get(:@arguments)).each_with_index do |arg, count|
        yield arg
        if count<(len-1)
          @f.write(",")
        end
      end
      @f.write(");\n")
    end
  end
end

def getconstantnode(name)
  @f.write(name)
end

def nodenode(nod)
  yield nod
end

def literalnode(node)
  # puts node.class
  if node.instance_of?(String)
    @f.write('"')
    yield node
    @f.write('"')
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

class AwesomePHP
  def initialize(inputfile, outputfile)
    @input = inputfile
    @output = outputfile
  end
  
  def parse
    # input
    code = ''
    File.open(@input, 'r') do |file|  
      while line = file.gets  
        code << line  
      end  
    end
    
    p objects = Parser.new.parse(code)

    # output
    @f = File.open(@output, "w")
    @f.write("<?php\n\n")
    if objects.instance_of?(Nodes)
      objarray = objects.instance_variable_get(:@nodes)
      objarray.each do |object|
        @f.write( node(object))
      end
    end
    @f.close()
  end
end

parsing = AwesomePHP.new(ARGV[0], ARGV[1])
parsing.parse()

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
