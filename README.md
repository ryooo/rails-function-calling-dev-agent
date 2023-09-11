# What is this

This is a proof of concept that aims to create a PR on CI based on the content written in the issue.
After giving the issue the llm-dev label, run the `rails llm:dev` command within ci.
Within the command, two llm agents(the Programmer and the Reviewer), use Function Calling to fulfill their roles and complete the pull request.

# How to use pair programming with GPT-4-32k

```ruby
prompt = "AzureOpenAi::Functions::ReadFileのrspecを追加してください。"
programmer = AzureOpenAi::Agents::Programmer.new(prompt, :cyan)
reviewer = AzureOpenAi::Agents::Reviewer.new(prompt, :green)

reviewer_comment = nil
i = 0
while (i += 1) < 20
  programmer_comment = programmer.work(reviewer_comment:)
  reviewer_comment = reviewer.work(programmer_comment:)

  break if reviewer.lgtm?
end

if reviewer.lgtm?
  programmer.make_pr!
end
```

# How to set function calling on chat parameter

```ruby
prompt = "AzureOpenAi::Functions::ReadFileのrspecを追加してください。"
azure_open_ai = AzureOpenAi::Client.new
io, _, _ = azure_open_ai.chat_with_function_calling_loop(
  messages: [{ role: :user, content: prompt }],
  functions: [
    AzureOpenAi::Functions::GetFilesList.new,
    AzureOpenAi::Functions::ReadFile.new,
    AzureOpenAi::Functions::AppendTextToFile.new,
    AzureOpenAi::Functions::ModifyTextOfFile.new,
    AzureOpenAi::Functions::MakeNewFile.new,
    AzureOpenAi::Functions::ExecRspecTest.new,
    AzureOpenAi::Functions::ExecShellCommand.new,
    AzureOpenAi::Functions::GoogleSearch.new,
    AzureOpenAi::Functions::OpenUrl.new(prompt),
  ],
  color: :cyan,
  actor_name: "Programmer",
)
```

# How to develop on local
```bash
bundle install
PROMPT=AzureOpenAi::Functions::ReadFileのrspecを追加してください bundle exec rails llm:dev
```

# required env
- must
  - AZURE_OPENAI_API_KEY
- for google custom search
  - GOOGLE_CUSTOM_SEARCH_CSE_ID
  - GOOGLE_SA_PRIVATE_KEY
  - GOOGLE_SA_CLIENT_EMAIL