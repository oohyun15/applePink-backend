unless Rails.env.development?
  Delayed::Backend::ActiveRecord::Job.singleton_class.prepend(
    Module.new do
      def reserve(*)
        previous_level = ::ActiveRecord::Base.logger.level
        ::ActiveRecord::Base.logger.level = Logger::WARN if previous_level < Logger::WARN
        value = super
        ::ActiveRecord::Base.logger.level = previous_level
        value
      end
    end
  )
  system 'RAILS_ENV=production bin/delayed_job start'
  system 'RAILS_ENV=production bin/delayed_job stop'
end