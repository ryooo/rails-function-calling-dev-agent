namespace :i18n do
  task update: :environment do
    I18nTranslator.update_dictionary!
  end
end
