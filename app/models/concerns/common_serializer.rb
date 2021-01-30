module CommonSerializer
  extend ActiveSupport::Concern
  included do
    def timestamp(val)
      time = time_ago_in_words(val)
      time =~ /약 / ? time[2..]+" 전" : time+" 전"
    end
  end
end
