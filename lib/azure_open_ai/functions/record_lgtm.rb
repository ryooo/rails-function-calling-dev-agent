module AzureOpenAi
  module Functions
    class RecordLgtm < Base
      def initialize
        @lgtm = false
      end

      def lgtm?
        !!@lgtm
      end

      def self.definition
        return @definition if @definition.present?

        @definition = {
          name: self.function_name,
          description: "Record LGTM for the diff.",
          parameters: {
            type: :object,
            properties: {},
          },
        }
        @definition
      end

      def execute_and_generate_message(args)
        @lgtm = true

        {result: "success"}
      end
    end
  end
end
