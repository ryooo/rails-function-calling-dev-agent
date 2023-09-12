module I18n
  def self.just_raise_that_exception(*args)
    Rails.logger.error args.first
    raise "i18n: #{args.first}" unless Rails.env.production?
  end
end
I18n.exception_handler = :just_raise_that_exception