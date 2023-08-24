require 'fastlane/action'

module Fastlane
  module Actions
    class JiraIssueSummaryAction < Action
      def self.run(params)
        Actions.verify_gem!('jira-ruby')
        require 'jira-ruby'

        client = JIRA::Client.new(
          username:     params[:username],
          password:     params[:password],
          site:         params[:url],
          context_path: '',
          auth_type:    :basic
        )

        keys = params[:issues].join(",")
        issues = []
        if keys.empty?
          return UI.message("No related issues")
        end
        jql = "ISSUE in (#{keys})"
        UI.message("execute JQL: #{jql}")
        issues = client.Issue.jql(jql)

        UI.message("#{issues.count()} issues found")


        case params[:format]
        when "plain"
          Helper::JiraHelper.plain_format(issues)
        when "html"
          Helper::JiraHelper.html_format(issues, params[:url])
        else
          issues
        end

      rescue JIRA::HTTPError => e
        fields = [e.code, e.message]
        fields << e.response.body if e.response.content_type == "application/json"
        UI.user_error!("#{e} #{fields.join(', ')}")
      end

      def self.description
        "Retreive issue summary on JIRA"
      end

      def self.authors
        ["Eric Hsu"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "Retreive issue summary on JIRA"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :url,
                                       env_name: "FL_JIRA_SITE",
                                       description: "URL for Jira instance",
                                       verify_block: proc do |value|
                                         UI.user_error!("No url for Jira given") if value.to_s.length == 0
                                       end),
          FastlaneCore::ConfigItem.new(key: :username,
                                       env_name: "FL_JIRA_USERNAME",
                                       description: "Username for Jira instance",
                                       verify_block: proc do |value|
                                         UI.user_error!("No username") if value.to_s.length == 0
                                       end),
          FastlaneCore::ConfigItem.new(key: :password,
                                       env_name: "FL_JIRA_PASSWORD",
                                       description: "Password or api token for Jira",
                                       sensitive: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("No password") if value.to_s.length == 0
                                       end),
          FastlaneCore::ConfigItem.new(key: :issues,
                                       env_name: "FL_JIRA_ISSUES",
                                       description: "Jira issue keys",
                                       type: Array,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :format,
                                       env_name: "FL_JIRA_RELEASE_NOTES_FORMAT",
                                       description: "Format text. Plain, html or none",
                                       sensitive: true,
                                       default_value: "plain"),
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
