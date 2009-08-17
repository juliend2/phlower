require "lexer"

code = <<-EOS
if 1:
  print "..."
  if false:
    pass
  print "done!"
print "The End"
EOS

p Lexer.new.tokenize(code)
# [[:IF, "if"], [:NUMBER, 1],
#  [:INDENT, 2], [:IDENTIFIER, "print"], [:STRING, "..."], [:NEWLINE, "\n"],
#                [:IF, "if"], [:IDENTIFIER, "false"],
#                [:INDENT, 4], [:IDENTIFIER, "pass"],
#                [:DEDENT, 2], [:NEWLINE, "\n"],
#                [:IDENTIFIER, "print"], [:STRING, "done!"],
#  [:DEDENT, 0], [:NEWLINE, "\n"],
#  [:IDENTIFIER, "print"], [:STRING, "The End"]]