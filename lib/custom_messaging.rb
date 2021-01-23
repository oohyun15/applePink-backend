if defined?(Slackistrano::Messaging)
  module Slackistrano
    class CustomMessaging < Messaging::Base

      # Send failed message to #ops. Send all other messages to default channels.
      # The #ops channel must exist prior.
      def channels_for(action)
        if action == :failed
          "#ops"
        else
          super
        end
      end

      # Suppress starting message.
      def payload_for_starting
        nil
      end

      # Suppress updating message.
      def payload_for_updating
        nil
      end

      # Suppress reverting message.
      def payload_for_reverting
        nil
      end

      # Fancy updated message.
      # See https://api.slack.com/docs/message-attachments
      def payload_for_updated
        {
          attachments: [{
            color: 'good',
            title: 'Success Deployed :rocket:',
            fields: [{
              title: 'Environment',
              value: stage,
              short: true
            }, {
              title: 'Branch',
              value: branch,
              short: true
            }, {
              title: 'Deployer',
              value: deployer,
              short: true
            }, {
              title: 'Time',
              value: elapsed_time,
              short: true
            }],
            fallback: super[:text]
          }],
          text: "<!here> 모두나눔 배포 완료!"
        }
      end

      # Default reverted message.  Alternatively simply do not redefine this
      # method.
      def payload_for_reverted
        super
      end

      # Slightly tweaked failed message.
      # See https://api.slack.com/docs/message-formatting
      def payload_for_failed
        # payload = super
        # payload[:text] = "OMG :fire: #{payload[:text]}"
        # payload
        {
          attachments: [{
            color: 'danger',
            title: 'Fail Deployed :boom:',
            fields: [{
              title: 'Environment',
              value: stage,
              short: true
            }, {
              title: 'Branch',
              value: branch,
              short: true
            }, {
              title: 'Deployer',
              value: deployer,
              short: true
            }, {
              title: 'Time',
              value: elapsed_time,
              short: true
            }],
            fallback: super[:text]
          }],
          text: "<!here> 모두나눔 배포 실패!"
        }
      end

      # Override the deployer helper to pull the best name available (git, password file, env vars).
      # See https://github.com/phallstrom/slackistrano/blob/master/lib/slackistrano/messaging/helpers.rb
      def deployer
        name = `git config user.name`.strip
        name = nil if name.empty?
        name ||= Etc.getpwnam(ENV['USER']).gecos || ENV['USER'] || ENV['USERNAME']
        name
      end
    end
  end
end