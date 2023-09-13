namespace :llm do
  task dev: :environment do
    prompt = ENV['PROMPT']
    if prompt.blank?
      raise 'prompt is required' if ENV['ISSUE_TITLE'].blank?
      prompt = "title: #{ENV['ISSUE_TITLE']}\ndescription: #{ENV['ISSUE_DESCRIPTION']}"
    end
    puts("Engineer leader: #{prompt}".light_red)

    programmer = Llm::Agents::Programmer.new(prompt, :cyan)
    reviewer = Llm::Agents::Reviewer.new(prompt, :green)
    reviewer_comment = nil
    i = 0
    while (i += 1) < 10
      programmer_comment = programmer.work(reviewer_comment:)
      reviewer_comment = reviewer.work(programmer_comment:)

      break if reviewer.lgtm?
    end

    if reviewer.lgtm?
      programmer.make_pr!
    end
  end
end
