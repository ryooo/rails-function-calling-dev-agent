class Translator
  DICTIONARY_PATH = Rails.root.join("config/translator.yml")

  def self.dictionary
    @dictionary ||= YAML.load(File.read(DICTIONARY_PATH)) rescue {}
  end

  def self.translator
    @translator ||= AzureOpenAi::Client.new
  end

  def self.to_en(word)
    (self.dictionary[word] || {})[:en] || word
  end

  def self.update_dictionary!
    require "parser/current"
    file_paths = Dir.glob(Rails.root.join("**/*.rb"))
    all_strs = file_paths.map do |file_path|
      tree = Parser::CurrentRuby.parse(File.read(file_path))
      tree.nil? ? [] : self.find_translator_strs(tree.loc.node, :to_en)
    end.flatten.uniq
    before_dictionary = self.dictionary.deep_dup
    updated_dictionary = {}.select {|str| str.present?}
    all_strs.each do |str|
      updated_dictionary[str] ||= (before_dictionary[str] || {})
      if updated_dictionary[str][:en].blank?
        updated_dictionary[str][:en] = self.translate(str)
        sleep(1)
        puts("#{str} => #{updated_dictionary[str][:en]}")
      end
    end
    File.write(DICTIONARY_PATH, YAML.dump(updated_dictionary))
  end

  def self.find_translator_strs(node, method_name)
    found_nodes = self.find_translator_node(node, method_name)
    strs = found_nodes.map { | found_node | self.find_str_node(found_node)}
    strs.select {|str| str.present?}
  end

  def self.find_str_node(node)
    # 変数埋め込みや変数結合には非対応で、純粋な文字列だけに対応
    ret = []
    ret << node.children[0] if node.type == :str
    node.children.each do |child|
      if child.is_a?(Parser::AST::Node)
        result = self.find_str_node(child)
        ret << result if result.present?
      end
    end
    ret.flatten.join
  end

  def self.find_translator_node(node, method_name)
    ret = []
    ret << node if node.type == :send && node.children[1] == method_name
    node.children.each do |child|
      if child.is_a?(Parser::AST::Node)
        result = self.find_translator_node(child, method_name)
        ret << result if result.present?
      end
    end
    ret.flatten
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
    ret.dig("choices", 0, "message", "content")
  end
end
