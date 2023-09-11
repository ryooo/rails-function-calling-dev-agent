class String
  def to_en
    Translator.to_en(self)
  end

  def wrap_as_markdown
    "```\n#{self}\n```"
  end
end
