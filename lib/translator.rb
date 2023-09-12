class Translator
  def self.update_dictionary!
    ja_file_paths = Dir.glob(Rails.root.join("config/locales/**/ja.yml"))
    ja_file_paths.each do |ja_file_path|
      ja = YAML.load(File.read(ja_file_path))
      en_file_path = ja_file_path.gsub(/ja\.yml$/, "en.yml")
      en = File.exist?(en_file_path) ? YAML.load(File.read(en_file_path)) : {}
      en = deep_translate(ja, en)
      File.write(en_file_path, YAML.dump(en))
    end
  end

  def self.deep_translate(ja, en)
    ja.each do |ja_k, v|
      en_k = ja_k == :ja.to_s ? :en.to_s : ja_k
      if v.is_a?(Hash)
        en[en_k] = deep_translate(v, en[en_k] || {})
      else
        if en[en_k].blank?
          en[en_k] = translate(v)
        end
      end
    end
    en
  end

  def self.translator
    @translator ||= AzureOpenAi::Client.new
  end

  def self.translate(str)
    # DeepLのほうが望ましいがLLMで代用
    ret = self.translator.chat(parameters: {
      messages: [
        {
          role: "system",
          content: "You are an excellent translator. We translate strings sent by users into accurate English.\n" + \
            "We do not output any content other than the translation.\n" + \
            "Please keep the position and number of the new line code(\\n).\n" + \
            "Never omit the line feed code at the end of a sentence.",
        },
        {
          role: "user",
          content: str,
        }
      ]
    })
    translated = ret.dig("choices", 0, "message", "content")
    puts("#{str} => #{translated.green}")
    sleep(1)
    translated
  end
end
