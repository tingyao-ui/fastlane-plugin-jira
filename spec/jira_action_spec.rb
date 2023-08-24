describe Fastlane::Actions::JiraAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The jira plugin is working!")

      Fastlane::Actions::JiraAction.run(nil)
    end
  end
end
