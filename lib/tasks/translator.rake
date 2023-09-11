namespace :translator do
  task update: :environment do
    Translator.update_dictionary!
  end
end
