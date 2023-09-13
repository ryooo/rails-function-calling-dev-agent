class LlmController < ApplicationController
  def new
  end

  def create
    prompt = params[:prompt]

    if prompt.blank?
      raise 'prompt is required'
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