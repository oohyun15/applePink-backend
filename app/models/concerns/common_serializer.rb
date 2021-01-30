module CommonSerializer
  extend ActiveSupport::Concern
  included do
    def timestamp(val)
      time = time_ago_in_words(val)
      time[2..] if time =~ /약 /
      time
    end
  end
end
