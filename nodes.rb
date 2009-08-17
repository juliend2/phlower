# Collection of nodes each one representing an expression.
class Nodes
  def initialize(nodes)
    @nodes = nodes
  end
  
  def <<(node)
    @nodes << node
    self
  end
  
  # This method is the "interpreter" part of our language.
  # All nodes know how to eval itself and returns the result
  # of its evaluation.
  # The "context" variable is the environment in which the node
  # is evaluated (local variables, current class, etc.).
  def eval(context)
    # The last value evaluated in a method is the return value.
    @nodes.map { |node| node.eval(context) }.last
  end
end

# Literals are static values that have a Ruby representation,
# eg.: a string, a number, true, false, nil, etc.
class LiteralNode
  def initialize(value)
    @value = value
  end
  
  def eval(context)
    case @value
    when Numeric
      Runtime["Number"].new_value(@value)
    when String
      Runtime["String"].new_value(@value)
    when TrueClass
      Runtime["true"]
    when FalseClass
      Runtime["false"]
    when NilClass
      Runtime["nil"]
    else
      raise "Unknown literal type: " + @value.class.name
    end
  end
end

# Node of a method call or local variable access,
# can take any of these forms:
# 
#   method # this form can also be a local variable
#   method(argument1, argument2)
#   receiver.method
#   receiver.method(argument1, argument2)
#
class CallNode
  def initialize(receiver, method, arguments=[])
    @receiver = receiver
    @method = method
    @arguments = arguments
  end
  
  def eval(context)
    # If there's no receiver and the method name is
    # the name of a local variable, then it's a local
    # variable access.
    # This trick allows us to skip the () when calling
    # a method.
    if @receiver.nil? && context.locals[@method]
      context.locals[@method]
    
    # Method call
    else
      # In case there's no receiver we default to self
      # So that calling "print" is like "self.print".
      if @receiver
        receiver = @receiver.eval(context)
      else
        receiver = context.current_self
      end
      arguments = @arguments.map { |arg| arg.eval(context) }
      receiver.call(@method, arguments)
    end
  end
end

# Retreiving the value of a constant.
class GetConstantNode
  def initialize(name)
    @name = name
  end
  
  def eval(context)
    context[@name]
  end
end

# Setting the value of a constant.
class SetConstantNode
  def initialize(name, value)
    @name = name
    @value = value
  end
  
  def eval(context)
    context[@name] = @value.eval(context)
  end
end

# Setting the value of a local variable.
class SetLocalNode
  def initialize(name, value)
    @name = name
    @value = value
  end
  
  def eval(context)
    context.locals[@name] = @value.eval(context)
  end
end

# Method definition.
class DefNode
  def initialize(name, params, body)
    @name = name
    @params = params
    @body = body
  end
  
  def eval(context)
    context.current_class.awesome_methods[@name] = AwesomeMethod.new(@params, @body)
  end
end

# Class definition.
class ClassNode
  def initialize(name, body)
    @name = name
    @body = body
  end
  
  def eval(context)
    # Create the class and put it's value in a constant.
    awesome_class = AwesomeClass.new
    context[@name] = awesome_class
    
    # Evaluate the body of the class in its context.
    @body.eval(Context.new(awesome_class, awesome_class))
    
    awesome_class
  end
end

# if-else control structure.
# Look at this node if you want to implement other
# control structures like while, for, loop, etc.
class IfNode
  def initialize(condition, body, else_body=nil)
    @condition = condition
    @body = body
    @else_body = else_body
  end
  
  def eval(context)
    # We turn the condition node into a Ruby value
    # to use Ruby's "if" control structure.
    if @condition.eval(context).ruby_value
      @body.eval(context)
    elsif @else_body
      @else_body.eval(context)
    end
  end
end