require 'spec_helper'

describe Message do
  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:author) }
    it { should validate_presence_of(:password) }
    it { should_not validate_presence_of(:mail) }
    it { should allow_value('mackerel-chef@example.com').for(:mail)}
    it { should_not allow_value('mackerel-chef.@example.com').for(:mail)}
    it { should_not validate_presence_of(:homepage) }
    it { should allow_value('http://www.asahi.com').for(:homepage)}
    it { should allow_value('https://www.asahi.com').for(:homepage)}
    it { should_not allow_value('www.asahi.com').for(:homepage)}
    it { should validate_presence_of(:content) }
    it { should_not validate_presence_of(:remote_addr) }
    it { should_not validate_presence_of(:user_agent) }

    it { should_not validate_presence_of(:old_id) }
    it { should_not validate_presence_of(:message_type) }
  end
end
