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


p Parser.new.parse(code)
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
