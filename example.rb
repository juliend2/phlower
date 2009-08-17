require "parser"
require "runtime"

code = <<-EOS
class Awesome:
  def does_it_work:
    "yeah!"

awesome_object = Awesome.new
if awesome_object:
  print("awesome_object.does_it_work: ")
  print(awesome_object.does_it_work)
else:
  print("Something is wrong...")
EOS

nodes = Parser.new.parse(code)
nodes.eval(Runtime)
