require 'spec_helper'

describe Comment do
  # describe "validations" do
  #   it { expect(subject).to validate_presence_of(:message_id) }
  #   it { expect(subject).to validate_presence_of(:title) }
  #   it { expect(subject).to validate_presence_of(:author) }
  #   it { expect(subject).to validate_presence_of(:password) }
  #   it { expect(subject).not_to validate_presence_of(:mail) }
  #   it { expect(subject).to allow_value('mackerel-chef@example.com').for(:mail) }
  #   it { expect(subject).not_to allow_value('mackerel-chef.@example.com').for(:mail) }
  #   it { expect(subject).not_to validate_presence_of(:homepage) }
  #   it { expect(subject).to allow_value('http://www.asahi.com').for(:homepage) }
  #   it { expect(subject).to allow_value('https://www.asahi.com').for(:homepage) }
  #   it { expect(subject).not_to allow_value('www.asahi.com').for(:homepage) }
  #   it { expect(subject).to validate_presence_of(:content) }
  #   it { expect(subject).not_to validate_presence_of(:remote_addr) }
  #   it { expect(subject).not_to validate_presence_of(:user_agent) }
  #
  #   it { expect(subject).not_to validate_presence_of(:old_id) }
  #   it { expect(subject).not_to validate_presence_of(:message_type) }
  # end

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

      it { expect(subject.title).to eq "Re: Greetings!" }
      it {
        content = I18n.t('entry.wrote', author: 'mackerel-chef') + "\n"
        content += "> Hello!\n> World."
        expect(subject.content).to eq content
      }
    end

    context "replay to Comment" do
      let!(:target) { Comment.new(title: "Greetings!",
                                  author: "mackerel-chef",
                                  content: "Hello!\nWorld.") }

      before do
        comment.reply_to(target)
      end

      it { expect(subject.title).to eq "Re: Greetings!" }
      it {
        content = I18n.t('entry.wrote', author: 'mackerel-chef') + "\n"
        content += "> Hello!\n> World."
        expect(subject.content).to eq content
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
                           created_at: current_time - 24.hours,
                           updated_at: current_time - 24.hours)
      }

      it { expect(subject).not_to be_new_entry }
    end

    context "new entry" do
      let!(:comment) {
        FactoryGirl.create(:comment,
                           created_at: current_time - 24.hours + 1.second,
                           updated_at: current_time - 24.hours + 1.second)
      }

      it { expect(subject).to be_new_entry }
    end
  end

  describe "search_hit?" do
    context "hit" do
      let!(:comment) { Comment.new(title: "title", author: "author", content: "content") }

      it { expect(comment.search_hit?("title")).to be_truthy }
      it { expect(comment.search_hit?(" title")).to be_truthy }
      it { expect(comment.search_hit?("title ")).to be_truthy }
      it { expect(comment.search_hit?("t i t l e")).to be_truthy }
      it { expect(comment.search_hit?("hello  title  test")).to be_truthy }
      it { expect(comment.search_hit?("author")).to be_truthy }
      it { expect(comment.search_hit?("content")).to be_truthy }
      it { expect(comment.search_hit?("content ")).to be_truthy }
      it { expect(comment.search_hit?("title author be_truthy")).to be_truthy }
    end

    context "not hit" do
      let!(:comment) { Comment.new(title: "title", author: "author", content: "content") }

      it { expect(comment.search_hit?("")).not_to be_truthy }
      it { expect(comment.search_hit?("titles")).not_to be_truthy }
      it { expect(comment.search_hit?("authors")).not_to be_truthy }
      it { expect(comment.search_hit?("contents")).not_to be_truthy }
    end
  end

  describe "log_request" do
    let!(:updated_at) { Time.now - 1.minute }
    let!(:comment) { FactoryGirl.create(:comment, updated_at: updated_at) }

    before do
      request = double(ActionDispatch::Request)
      request.should_receive(:remote_addr).and_return('127.0.0.1')
      request.should_receive(:user_agent).and_return('rspec')

      comment.log_request(request)
    end

    it { expect(comment.remote_addr).to eq '127.0.0.1' }
    it { expect(comment.user_agent).to eq 'rspec' }
    it { expect(comment.updated_at).to be >  updated_at}
  end
end
