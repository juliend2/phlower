class Lexer
  KEYWORDS = ["def", "class", "if", "else", "true", "false", "nil"]

  def tokenize(code)
    # Cleanup code by remove extra line breaks
    code.chomp!
    
    # Current character position we're parsing
    i = 0
    
    # Collection of all parsed tokens in the form [:TOKEN_TYPE, value]
    tokens = []
    
    # Current indent level is the number of spaces in the last indent.
    current_indent = 0
    # We keep track of the indentation levels we are in so
    # that when we dedent, we can check if we're on the
    # correct level.
    indent_stack = []
    
    # This is how to implement a very simple scanner.
    # Scan one caracter at the time until you find something to parse.
    while i < code.size
      chunk = code[i..-1]
      
      # Matching standard tokens.
      #
      # Matching if, print, method names, etc.
      if identifier = chunk[/\A([_a-z@]\w*)/, 1]
        # Keywords are special identifiers tagged with their own
        # name, 'if' will result in an [:IF, "if"] token
        if KEYWORDS.include?(identifier)
          tokens << [identifier.upcase.to_sym, identifier]
        # Non-keyword identifiers include method and variable
        # names.
        else
          tokens << [:IDENTIFIER, identifier]
        end
        # skip what we just parsed
        i += identifier.size
      
      # Matching class names and constants.
      elsif constant = chunk[/\A([A-Z]\w*)/, 1]
        tokens << [:CONSTANT, constant]
        i += constant.size
        
      elsif number = chunk[/\A([0-9]+)/, 1]
        tokens << [:NUMBER, number.to_i]
        i += number.size
        
      elsif string = chunk[/\A"(.*?)"/, 1]
        tokens << [:STRING, string]
        i += string.size + 2
      
      # Here's the indentation magic!
      #
      # We have to take care of 3 cases:
      # 
      #   if true:  # 1) the block is created
      #     line 1
      #     line 2  # 2) new line inside a block
      #   continue  # 3) dedent
      #
      # This elsif takes care of the first case.
      # The number of spaces will determine the indent level.
      elsif indent = chunk[/\A\:\n( +)/m, 1]
        # When we create a new block we expect the indent level
        # to go up.
        if indent.size <= current_indent
          raise "Bad indent level, got #{indent.size} indents, " +
                "expected > #{current_indent}"
        end
        # Adjust the current indentation level.
        current_indent = indent.size
        indent_stack.push(current_indent)
        tokens << [:INDENT, indent.size]
        i += indent.size + 2
  
      # This one takes care of cases 2 and 3.
      # We stay in the same block if the indent level is the
      # same as current_indent, or close a block, if it is lower.
      elsif indent = chunk[/\A\n( *)/m, 1]
        if indent.size < current_indent
          indent_stack.pop
          current_indent = indent_stack.first || 0
          tokens << [:DEDENT, indent.size]
          tokens << [:NEWLINE, "\n"]
        elsif indent.size == current_indent
          # Nothing to do, we're still in the same block
          tokens << [:NEWLINE, "\n"]
        else # indent.size > current_indent
          # Cannot increase indent level without using ":", so
          # this is an error.
          raise "Missing ':'"
        end
        i += indent.size + 1
      
      # Ignore whitespace
      elsif chunk.match(/\A /)
        i += 1
      
      # We treat all other single characters as a token.
      # Eg.: ( ) , . !
      else
        value = chunk[0,1]
        tokens << [value, value]
        i += 1
        
      end
      
    end
    
    # Close all open blocks
    while indent = indent_stack.pop
      tokens << [:DEDENT, indent_stack.first || 0]
    end
    
    tokens
  end
end

# [[:DEF, "def"], [:IDENTIFIER, "pass"], ["(", "("], [")", ")"], 
#   [:INDENT, 2], [:IDENTIFIER, "echo"], ["(", "("], [:STRING, "joie"], [")", ")"], 
#   [:NEWLINE, "\n"], 
# [:DEDENT, 0], 
# [:NEWLINE, "\n"], 
# [:CLASS, "class"], [:CONSTANT, "Awesome"], 
#   [:INDENT, 2], [:DEF, "def"], [:IDENTIFIER, "init"], ["(", "("], [")", ")"], 
#     [:INDENT, 4], [:IDENTIFIER, "pass"], ["(", "("], [")", ")"], 
#   [:DEDENT, 2], 
#   [:NEWLINE, "\n"], 
#   [:NEWLINE, "\n"], 
#   [:DEF, "def"], [:IDENTIFIER, "x"], ["(", "("], [")", ")"], 
#     [:INDENT, 4], [:IDENTIFIER, "return"], ["(", "("], [:NUMBER, 2], ["+", "+"], [:NUMBER, 2], [")", ")"], 
#   [:DEDENT, 0], 
#   [:NEWLINE, "\n"], 
#   [:NEWLINE, "\n"], [:DEF, "def"], [:IDENTIFIER, "z"], ["(", "("], [")", ")"], 
#     [:INDENT, 4], [:IDENTIFIER, "print"], ["(", "("], [:STRING, "poulet"], [")", ")"], 
# [:DEDENT, 0], 
# [:NEWLINE, "\n"], 
# [:DEDENT, 0], 
# [:NEWLINE, "\n"], [:IDENTIFIER, "poulet"], ["=", "="], [:TRUE, "true"], 
# [:NEWLINE, "\n"], [:IF, "if"], [:IDENTIFIER, "poulet"], 
#   [:INDENT, 2], [:IDENTIFIER, "aw"], ["=", "="], [:CONSTANT, "Awesome"], [".", "."], [:IDENTIFIER, "new"], ["(", "("], [:STRING, "brilliant!"], [",", ","], [:NUMBER, 2], [")", ")"], 
#   [:NEWLINE, "\n"], [:IDENTIFIER, "pouti"], ["=", "="], [:IDENTIFIER, "aw"], [".", "."], [:IDENTIFIER, "x"], ["(", "("], [")", ")"], 
#   [:NEWLINE, "\n"], [:IDENTIFIER, "awe"], ["=", "="], [:IDENTIFIER, "aw"], [".", "."], [:IDENTIFIER, "init"], ["(", "("], [")", ")"], [".", "."], [:IDENTIFIER, "x"], ["(", "("], [")", ")"], [".", "."], [:IDENTIFIER, "z"], ["(", "("], [")", ")"], 
#   [:NEWLINE, "\n"], [:IDENTIFIER, "print"], ["(", "("], [:IDENTIFIER, "awe"], [")", ")"], 
# [:DEDENT, 0], 
# [:NEWLINE, "\n"], [:ELSE, "else"], 
#   [:INDENT, 2], [:IDENTIFIER, "weird"], ["(", "("], [")", ")"], 
# [:DEDENT, 0], 
# [:NEWLINE, "\n"]]