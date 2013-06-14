require 'spec_helper'

describe Message do
  describe "validations" do
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

  describe "current_page" do
    let!(:message) { FactoryGirl.create(:message) }

    subject { message }

    before do
      Kaminari.config.default_per_page = 10
      relation = mock(ActiveRecord::Relation)
      relation.should_receive(:count).and_return(101)
      Message.should_receive(:newer).and_return(relation)
    end

    its(:current_page) { should == 11 }
  end

  describe "new_entry?" do
    subject { message }

    let!(:current_time) { Time.now }

    before do
      Time.stub(:now).and_return(current_time)
    end

    context "not new entry" do
      let!(:message) {
        FactoryGirl.create(:message,
                           created_at: current_time - 24.hours,
                           updated_at: current_time - 24.hours)
      }

      it { should_not be_new_entry }
    end

    context "new entry" do
      let!(:message) {
        FactoryGirl.create(:message,
                           created_at: current_time - 24.hours + 1.second,
                           updated_at: current_time - 24.hours + 1.second)
      }

      it { should be_new_entry }
    end
  end

  describe "search_hit?" do
    let!(:message) { Message.new(title: "title", author: "author", content: "content") }

    context "hit" do
      it { message.search_hit?("title").should be_true }
      it { message.search_hit?(" title").should be_true }
      it { message.search_hit?("title ").should be_true }
      it { message.search_hit?("t i t l e").should be_true }
      it { message.search_hit?("hello  title  test").should be_true }
      it { message.search_hit?("author").should be_true }
      it { message.search_hit?("content").should be_true }
      it { message.search_hit?("content ").should be_true }
      it { message.search_hit?("title author content").should be_true }
    end

    context "not hit" do
      it { message.search_hit?("").should_not be_true }
      it { message.search_hit?("titles").should_not be_true }
      it { message.search_hit?("authors").should_not be_true }
      it { message.search_hit?("contents").should_not be_true }
    end
  end

  describe "log_request" do
    let!(:updated_at) { Time.now - 1.minute }
    let!(:message) { FactoryGirl.create(:message, updated_at: updated_at) }

    before do
      request = mock(ActionDispatch::Request)
      request.should_receive(:remote_addr).and_return('127.0.0.1')
      request.should_receive(:user_agent).and_return('rspec')

      message.log_request(request)
    end

    it { message.remote_addr.should == '127.0.0.1' }
    it { message.user_agent.should == 'rspec' }
    it { message.updated_at.should >  updated_at}
  end
end
