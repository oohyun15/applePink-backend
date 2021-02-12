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
            title: 'Success Deployed! :rocket:',
            fields: [{
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
            }, {
              title: 'Compare',
              value: "<#{repo_url}/compare/#{prev_hash}...#{last_hash}|check :mag:>",
              short: true,
            }, {
              title: 'Commits',
              value: update_commits.join("\n")
            }],
            fallback: super[:text]
          }],
          text: "모두나눔 배포 완료! <!here|here>"
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
              title: 'Branch',
              value: branch,
              short: true
            }, {
              title: 'Deployer',
              value: deployer,
              short: true
            }, {
              title: 'Backtrace',
              value: $!.backtrace.join("\n")
            }],
            fallback: super[:text]
          }],
          text: "모두나눔 배포 실패! <!here|here>"
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

      def update_commits
        commits = []
        if prev_hash != last_hash
          diff =`git log #{prev_hash}..#{last_hash} --format=format:'%s%x00%an%x00%ar%x00%h'`
          diff.split("\n").each do |commit|
            subject, author, date, hash = commit.split("\u0000")
            cm = "<#{repo_url}/commit/#{hash[0..6]}|`#{hash[0..6]}`>"
            cm +=  " #{subject} - #{author} (#{date})"
            commits << cm
          end
        end
        commits.reverse
      end

      def repo_url
        return @repo_url unless @repo_url.nil?

        origin = fetch(:repo_url).split(":")[1].strip
        origin = origin[0..-5] if origin.end_with?(".git")
        @repo_url = origin.include?("github.com") ? origin : "https://github.com/#{origin}"
      end

      def prev_hash
        @prev_hash ||= fetch(:previous_revision) || ''
      end

      def last_hash
        @last_hash ||= `git rev-parse origin/#{fetch(:branch)}`.strip!
      end
    end
  end
end