namespace :llm do
  task exec: :environment do |task, args|
    prompt = "藤井聡太の近況ってどんな感じ？"
    azure_open_ai = AzureOpenAi::Client.new
    io, _, _ = azure_open_ai.chat_with_function_calling_loop(
      messages: [{ role: "user", content: prompt }],
      functions: [
        AzureOpenAi::Functions::GoogleSearch.new,
        AzureOpenAi::Functions::OpenUrl.new(prompt),
      ],
    )
    puts(io.rewind && io.read)
  end
end
