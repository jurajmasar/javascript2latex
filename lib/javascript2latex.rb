#
# Utility class for creating a latex expression from a JavaScript expression.
#
# @author Juraj Masar <mail@jurajmasar.com> 1st May 2013
#
class Javascript2latex
  #
  # Node representation of a part of the mathematical expression used for
  # transforming of the javascript expression into a latex expression.
  #
  class ExpressionNode
    attr_accessor :type, :left, :right, :value

    SQRT_EXPRESSION = 'Math.sqrt('
    POWER_EXPRESSION = 'Math.pow('
    LOG_EXPRESSION = 'Math.log('

    ARGUMENT_EXCEPTION_MESSAGE = 'Argument is not a valid javascript expression'

    def initialize(javascript_expression)
      # validate parameters
      raise ArgumentError, ARGUMENT_EXCEPTION_MESSAGE if javascript_expression.nil? or javascript_expression.empty?

      # remove all whitespaces
      javascript_expression.gsub!(/\s+/, '')

      # remove enclosing brackets
      #
      is_enclosed_in_brackets = true
      while is_enclosed_in_brackets and javascript_expression[0] == '(' and javascript_expression[-1,1] == ')'
        # remember how many opening brackets have we encountered
        bracket_level = 0

        # iterate over expression and decide whether it is enclosed in brackets
        # e.g. (a) is OK but (a)/(b) is not, although both pass the condition in while
        javascript_expression.split('').each_with_index do |char, index|
          bracket_level += 1 if char == '('
          bracket_level -= 1 if char == ')'

          if bracket_level == 0 and index != 0 and index != javascript_expression.length-1
            is_enclosed_in_brackets = false
            break
          end
        end

        # remove brackets if they are enclosing the entire expression
        javascript_expression = javascript_expression[1,javascript_expression.length-2] if is_enclosed_in_brackets
      end

      # check for equal sign
      if !javascript_expression.index('=').nil?
        index = javascript_expression.index('=')
        @type = :equals
        @left = ExpressionNode.new(javascript_expression[0, index])
        @right = ExpressionNode.new(javascript_expression[index+1, javascript_expression.length-index-1])
        return
      end

      # check for square root
      if javascript_expression[0,SQRT_EXPRESSION.length] == SQRT_EXPRESSION && javascript_expression[-1,1] == ')'
        # remember how many opening brackets have we encountered
        bracket_level = 0
        is_enclosed_in_brackets = true
        # iterate over expression and decide whether it is enclosed in brackets
        # e.g. Math.sqrt(a) is OK but Math.sqrt(a)/(b) is not, although both pass the condition above
        javascript_expression.split('').each_with_index do |char, index|
          bracket_level += 1 if char == '('
          bracket_level -= 1 if char == ')'

          if bracket_level == 0 and index > SQRT_EXPRESSION.length-1 and index != javascript_expression.length-1
            is_enclosed_in_brackets = false
            break
          end
        end

        if is_enclosed_in_brackets
          @type = :sqrt
          @left = ExpressionNode.new(javascript_expression[SQRT_EXPRESSION.length,javascript_expression.length-SQRT_EXPRESSION.length-1])
          return
        end
      end

      # check for logarithm
      if javascript_expression[0,LOG_EXPRESSION.length] == LOG_EXPRESSION && javascript_expression[-1,1] == ')'
        # remember how many opening brackets have we encountered
        bracket_level = 0
        is_enclosed_in_brackets = true
        # iterate over expression and decide whether it is enclosed in brackets
        # e.g. Math.log(a) is OK but Math.log(a)/(b) is not, although both pass the condition above
        javascript_expression.split('').each_with_index do |char, index|
          bracket_level += 1 if char == '('
          bracket_level -= 1 if char == ')'

          if bracket_level == 0 and index > LOG_EXPRESSION.length-1 and index != javascript_expression.length-1
            is_enclosed_in_brackets = false
            break
          end
        end

        if is_enclosed_in_brackets
          @type = :log
          @left = ExpressionNode.new(javascript_expression[LOG_EXPRESSION.length,javascript_expression.length-LOG_EXPRESSION.length-1])
          return
        end
      end

      # check for power
      if javascript_expression[0,POWER_EXPRESSION.length] == POWER_EXPRESSION && javascript_expression[-1,1] == ')'
        # remember how many opening brackets have we encountered
        bracket_level = 0
        is_enclosed_in_brackets = true

        # iterate over expression and decide whether it is enclosed in brackets
        # e.g. Math.pow(a) is OK but Math.pow(a)/(b) is not, although both pass the condition above
        javascript_expression.split('').each_with_index do |char, index|
          bracket_level += 1 if char == '('
          bracket_level -= 1 if char == ')'

          if bracket_level == 0 and index > POWER_EXPRESSION.length-1 and index != javascript_expression.length-1
            is_enclosed_in_brackets = false
            break
          end
        end

        if is_enclosed_in_brackets
          # iterate over inner expression in order to find comma
          javascript_expression[POWER_EXPRESSION.length,javascript_expression.length-POWER_EXPRESSION.length-1].split('').each_with_index do |char, index|
            bracket_level += 1 and next if char == '('
            bracket_level -= 1 and next if char == ')'

            if char == ',' and bracket_level == 0
              @type = :power
              @left = ExpressionNode.new(javascript_expression[POWER_EXPRESSION.length, index])
              @right = ExpressionNode.new(javascript_expression[POWER_EXPRESSION.length+index+1, javascript_expression.length-POWER_EXPRESSION.length-index-2])
              return
            end
          end

          # comma was not found, input is corrupted
          raise ArgumentError, ARGUMENT_EXCEPTION_MESSAGE and return
        end
      end

      # check for + and - iterate over given expression
      # remember how many open brackets have we encountered
      bracket_level = 0
      javascript_expression.split('').each_with_index do |char, index|
        bracket_level += 1 and next if char == '('
        bracket_level -= 1 and next if char == ')'
        if (char == '+' or char == '-') and bracket_level == 0
          @type = :addition if char == '+'
          @type = :subtraction if char == '-'
          @left = ExpressionNode.new(javascript_expression[0, index])
          @right = ExpressionNode.new(javascript_expression[index+1, javascript_expression.length-index-1])
          return
        end
      end

      # check for * and / iterate over given expression
      # remember how many open brackets have we encountered
      bracket_level = 0
      javascript_expression.split('').each_with_index do |char, index|
        bracket_level += 1 and next if char == '('
        bracket_level -= 1 and next if char == ')'
        if (char == '*' or char == '/') and bracket_level == 0
          @type = :multiplication if char == '*'
          @type = :division if char == '/'
          @left = ExpressionNode.new(javascript_expression[0, index])
          @right = ExpressionNode.new(javascript_expression[index+1, javascript_expression.length-index-1])
          return
        end
      end

      # if the expression is non-empty alphanumeric string
      if javascript_expression =~ /^[a-z0-9]+$/i
        @type = :value
        @value = javascript_expression
      else
        raise ArgumentError, ARGUMENT_EXCEPTION_MESSAGE and return
      end
    end

    #
    # Makes a latex expression from this node and all of its children.
    #
    # @return [String] latex expression
    def to_s
      case @type
        when :equals
          return "#{@left}=#{@right}"
        when :sqrt
          return "\\sqrt{#{@left}}"
        when :log
          body = @left.to_s

          # enclose body in brackets if it is a composite expression
          body = "(#{body})" if body !~ /^[a-z0-9]+$/i

          return "\\log{#{body}}"
        when :power
          base = @left.to_s
          exponent = @right.to_s

          # enclose base in brackets if it is a composite expression
          base = "(#{base})" if base !~ /^[a-z0-9]+$/i

          return "#{base}^{#{exponent}}"
        when :addition
          return "#{@left}+#{@right}"
        when :subtraction
          return "#{@left}-#{@right}"
        when :multiplication
          left = @left.to_s
          # check for + and - iterate over given expression
          has_to_be_enclosed_in_brackets = false
          # remember how many open brackets have we encountered
          bracket_level = 0
          left.split('').each_with_index do |char, index|
            bracket_level += 1 and next if char == '('
            bracket_level -= 1 and next if char == ')'
            if (char == '+' or char == '-') and bracket_level == 0
              has_to_be_enclosed_in_brackets = true
              break
            end
          end
          # enclose multiples in brackets if they are a composite expression
          left = "(#{left})" if has_to_be_enclosed_in_brackets

          right = @right.to_s
          # check for + and - iterate over given expression
          has_to_be_enclosed_in_brackets = false
          # remember how many open brackets have we encountered
          bracket_level = 0
          right.split('').each_with_index do |char, index|
            bracket_level += 1 and next if char == '('
            bracket_level -= 1 and next if char == ')'
            if (char == '+' or char == '-') and bracket_level == 0
              has_to_be_enclosed_in_brackets = true
              break
            end
          end

          right = "(#{right})" if has_to_be_enclosed_in_brackets

          return "#{left} \\times #{right}"
        when :division
          return "\\frac{#{@left}}{#{@right}}"
        when :value
          return @value
      end
    end
  end

  #
  # Converts the given mathematical expression written in JavaScript into latex syntax.
  #
  # @param [string] javascript_expression
  # @return [string] latex_expression
  def self.make_tex(javascript_expression)
    begin
      root = ExpressionNode.new(javascript_expression)
      return "$#{root}$"
    rescue
      return '$$'
      Rails.logger.error 'Invalid JavaScript expression'
    end
  end
end