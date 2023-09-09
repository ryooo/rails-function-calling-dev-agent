module AzureOpenAi
  class Client
    def initialize(timeout: 300)
      OpenAI.configure do |config|
        config.api_type = :azure
        config.api_version = "2023-07-01-preview"
      end

      @client = OpenAI::Client.new(
        access_token: ENV.fetch("AZURE_OPENAI_API_KEY"),
        uri_base: "https://japaneast.api.cognitive.microsoft.com/openai/deployments/gpt-4-32k#{Rails.env.production? ? '' : '-dev'}",
        request_timeout: timeout,
      )
    end

    def method_missing(method_name, *args)
      @client.__send__(method_name, *args)
    end

    def chat(parameters: {})
      parameters = parameters.with_indifferent_access
      parameters[:model] ||= "gpt-4-32k"
      parameters[:temperature] ||= 0.5
      parameters[:top_p] ||= 1
      parameters[:frequency_penalty] ||= 0
      parameters[:presence_penalty] ||= 0

      @client.chat(parameters: parameters)
    end

    def chat_with_function_calling_loop(**args)
      color = args.delete(:color) || (raise 'color is required.')
      actor_name = args.delete(:actor_name) || (raise 'actor_name is required.')
      chat_message_io = StringIO.new
      function_histories = []

      if args[:messages].is_a?(LlmMessageContainer)
        message_container = args[:messages]
      else
        message_container = LlmMessageContainer.new
        message_container.add_raw_messages(args[:messages])
      end

      i = 0
      while (i += 1) < 30
        ret = self.chat(parameters: args.merge({
          messages: message_container.to_capped_messages,
          functions: args[:functions].map { |f| f.class.definition },
        }))

        # Function calling
        if ret.dig("choices", 0, "finish_reason") == 'function_call'
          message = ret.dig("choices", 0, "message")
          function = args[:functions].detect { |f| f.function_name == message['function_call']['name'] }
          message_container.add_raw_message(message.merge({ content: nil }))

          function_args = (JSON.parse(message.dig('function_call','arguments')) || {}).with_indifferent_access
          puts("#{actor_name}: #{function.class.name.send(color)}")
          puts(function_args)
          function_result = function.execute_and_generate_message(function_args)
          # puts(function_result) if Rails.env.development?
          message_container.add_raw_message({
            role: "function",
            name: function.function_name,
            content: JSON.dump(function_result),
          })

          function_histories << {
            function_calling: message,
            result: function_result,
          }
        else
          break
        end
      end

      # メッセージ表示
      if content = ret.dig("choices", 0, "message", "content")
        chat_message_io.write(content)
      else
        chat_message_io.write(JSON.dump(ret))
      end
      [chat_message_io, function_histories, message_container]
    end
  end
end
