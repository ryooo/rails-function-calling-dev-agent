module AzureOpenAi
  module Functions
    class Base
      def self.function_name
        self.name.split("::").last.underscore
      end

      def function_name
        self.class.function_name;
      end
    end
  end
end
