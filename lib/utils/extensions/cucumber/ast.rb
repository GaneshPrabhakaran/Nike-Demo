module Cucumber
  module Ast
    class OutlineTable
      # @private
      # Defines a single example in an outline set.
      class ExampleRow
        def accept_expand(visitor)
          return if header?
          visitor.visit_example(self) do
            visitor.runtime.with_hooks(self) do
              @table.visit_scenario_name(visitor, self)
              @step_invocations.each do |step_invocation|
                visitor.visit_step(step_invocation)
                @exception ||= step_invocation.reported_exception
              end
            end
          end
        end
      end # ExampleRow
    end # OutlineTable

    # @private
    # Walks the AST, executing steps and notifying listeners
    class TreeWalker
      def visit_example(row, &block)
        broadcast row, &block
      end
    end # TreeWalker
  end # Ast
end # Cucumber
