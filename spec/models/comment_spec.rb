require 'spec_helper'

describe Comment do
  describe "validations" do
    it { should validate_presence_of(:message_id) }
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:author) }
    it { should validate_presence_of(:password) }
    it { should_not validate_presence_of(:mail) }
    it { should allow_value('mackerel-chef@example.com').for(:mail) }
    it { should_not allow_value('mackerel-chef.@example.com').for(:mail) }
    it { should_not validate_presence_of(:homepage) }
    it { should allow_value('http://www.asahi.com').for(:homepage) }
    it { should allow_value('https://www.asahi.com').for(:homepage) }
    it { should_not allow_value('www.asahi.com').for(:homepage) }
    it { should validate_presence_of(:content) }
    it { should_not validate_presence_of(:remote_addr) }
    it { should_not validate_presence_of(:user_agent) }

    it { should_not validate_presence_of(:old_id) }
    it { should_not validate_presence_of(:message_type) }
  end

  describe "reply_to" do
    let!(:comment) { Comment.new }

    subject { comment }

    context "reply to Message" do
      let!(:target) { Message.new(title: "Greetings!",
                                  author: "mackerel-chef",
                                  content: "Hello!\nWorld.") }

      before do
        comment.reply_to(target)
      end

      its(:title) { should == "Re: Greetings!" }
      its(:content) {
        content = I18n.t('entry.wrote', author: 'mackerel-chef') + "\n"
        content += "> Hello!\n> World."
        should == content
      }
    end

    context "replay to Comment" do
      let!(:target) { Comment.new(title: "Greetings!",
                                  author: "mackerel-chef",
                                  content: "Hello!\nWorld.") }

      before do
        comment.reply_to(target)
      end

      its(:title) { should == "Re: Greetings!" }
      its(:content) {
        content = I18n.t('entry.wrote', author: 'mackerel-chef') + "\n"
        content += "> Hello!\n> World."
        should == content
      }
    end
  end

  describe "new_entry?" do
    subject { comment }

    let!(:current_time) { Time.now }

    before do
      Time.stub(:now).and_return(current_time)
    end

    context "not new entry" do
      let!(:comment) {
        FactoryGirl.create(:comment,
                           message: FactoryGirl.create(:message_with_no_comment),
                           created_at: current_time - 24.hours,
                           updated_at: current_time - 24.hours)
      }

      it { should_not be_new_entry }
    end

    context "new entry" do
      let!(:comment) {
        FactoryGirl.create(:comment,
                           message: FactoryGirl.create(:message_with_no_comment),
                           created_at: current_time - 24.hours + 1.second,
                           updated_at: current_time - 24.hours + 1.second)
      }

      it { should be_new_entry }
    end
  end

  describe "search_hit?" do
    context "hit" do
      let!(:comment) { Comment.new(title: "title", author: "author", content: "content") }

      it { comment.search_hit?("title").should be_true }
      it { comment.search_hit?(" title").should be_true }
      it { comment.search_hit?("title ").should be_true }
      it { comment.search_hit?("t i t l e").should be_true }
      it { comment.search_hit?("hello  title  test").should be_true }
      it { comment.search_hit?("author").should be_true }
      it { comment.search_hit?("content").should be_true }
      it { comment.search_hit?("content ").should be_true }
      it { comment.search_hit?("title author content").should be_true }
    end

    context "not hit" do
      let!(:comment) { Comment.new(title: "title", author: "author", content: "content") }

      it { comment.search_hit?("").should_not be_true }
      it { comment.search_hit?("titles").should_not be_true }
      it { comment.search_hit?("authors").should_not be_true }
      it { comment.search_hit?("contents").should_not be_true }
    end
  end

  describe "log_request" do
    let!(:updated_at) { Time.now - 1.minute }
    let!(:comment) { FactoryGirl.create(:comment,
                                        updated_at: updated_at,
                                        message: FactoryGirl.create(:message_with_no_comment)) }

    before do
      request = mock(ActionDispatch::Request)
      request.should_receive(:remote_addr).and_return('127.0.0.1')
      request.should_receive(:user_agent).and_return('rspec')

      comment.log_request(request)
    end

    it { comment.remote_addr.should == '127.0.0.1' }
    it { comment.user_agent.should == 'rspec' }
    it { comment.updated_at.should >  updated_at}
  end
end
