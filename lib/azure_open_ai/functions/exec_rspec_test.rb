module AzureOpenAi
  module Functions
    class ExecRspecTest < Base
      def self.definition
        return @definition if @definition.present?

        @definition = {
          name: self.function_name,
          description: "rspecのテストを実行します。".to_en,
          parameters: {
            type: :object,
            properties: {
              file_or_dir_path: {
                type: :string,
                description: ("specファイルのファイルパスを指定します。" + \
                  "ディレクトリパスが指定された場合は、ディレクトリ内のすべてのspecファイルを実行します。").to_en,
              },
            },
            required: [:file_or_dir_path],
          },
        }
        @definition
      end

      def execute_and_generate_message(args)
        script = "bundle exec rspec '#{args['file_or_dir_path']}'"
        stdout, stderr, status = Open3.capture3(script)

        {stdout:, stderr:, exit_status: status.exitstatus}
      end
    end
  end
end
