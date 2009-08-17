class BracketLexer
  KEYWORDS = ["def", "class", "if", "else", "true", "false", "nil"]
  
  def tokenize(code)
    code.chomp!
    i = 0
    tokens = []
    current_indent = 0
    indent_stack = []
    
    while i < code.size
      chunk = code[i..-1]

      if identifier = chunk[/\A([a-z]\w*)/, 1]
        if KEYWORDS.include?(identifier)
          tokens << [identifier.upcase.to_sym, identifier]
        else
          tokens << [:IDENTIFIER, identifier]
        end
        i += identifier.size
      
      elsif constant = chunk[/\A([A-Z]\w*)/, 1]
        tokens << [:CONSTANT, constant]
        i += constant.size
        
      elsif number = chunk[/\A([0-9]+)/, 1]
        tokens << [:NUMBER, number.to_i]
        i += number.size
        
      elsif string = chunk[/\A"(.*?)"/, 1]
        tokens << [:STRING, string]
        i += string.size + 2
      
      # All indentation magic code was removed and only this elsif
      # was added.
      elsif chunk.match(/\A\n+/)
        tokens << [:NEWLINE, "\n"]
        i += 1
      
      elsif chunk.match(/\A /)
        i += 1
      
      else
        value = chunk[0,1]
        tokens << [value, value]
        i += 1
        
      end
      
    end
    
    tokens
  end
end

code = <<-EOS
if 1 {
  print "..."
  if false {
    pass
  }
  print "done!"
}
print "The End"
EOS

p BracketLexer.new.tokenize(code)
# [[:IF, "if"], [:NUMBER, 1], ["{", "{"], [:NEWLINE, "\n"],
#    [:IDENTIFIER, "print"], [:STRING, "..."], [:NEWLINE, "\n"],
#    [:IF, "if"], [:FALSE, "false"], ["{", "{"], [:NEWLINE, "\n"],
#      [:IDENTIFIER, "pass"], [:NEWLINE, "\n"],
#    ["}", "}"], [:NEWLINE, "\n"],
#    [:IDENTIFIER, "print"], [:STRING, "done!"], [:NEWLINE, "\n"],
#  ["}", "}"], [:NEWLINE, "\n"],
#  [:IDENTIFIER, "print"], [:STRING, "The End"]]