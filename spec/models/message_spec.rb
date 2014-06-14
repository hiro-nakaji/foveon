require 'spec_helper'

describe Message do
  describe "validations" do
    it { expect(subject).to validate_presence_of(:title) }
    it { expect(subject).to validate_presence_of(:author) }
    it { expect(subject).to validate_presence_of(:password) }
    it { expect(subject).not_to validate_presence_of(:mail) }
    it { expect(subject).to allow_value('mackerel-chef@example.com').for(:mail) }
    it { expect(subject).not_to allow_value('mackerel-chef.@example.com').for(:mail) }
    it { expect(subject).not_to validate_presence_of(:homepage) }
    it { expect(subject).to allow_value('http://www.asahi.com').for(:homepage) }
    it { expect(subject).to allow_value('https://www.asahi.com').for(:homepage) }
    it { expect(subject).not_to allow_value('www.asahi.com').for(:homepage) }
    it { expect(subject).to validate_presence_of(:content) }
    it { expect(subject).not_to validate_presence_of(:remote_addr) }
    it { expect(subject).not_to validate_presence_of(:user_agent) }

    it { expect(subject).not_to validate_presence_of(:old_id) }
    it { expect(subject).not_to validate_presence_of(:message_type) }
  end

  describe "current_page" do
    let!(:message) { FactoryGirl.create(:message) }

    subject { message }

    before do
      Kaminari.config.default_per_page = 10
      relation = double(ActiveRecord::Relation)
      relation.should_receive(:count).and_return(101)
      Message.should_receive(:newer).and_return(relation)
    end

    it { expect(subject.current_page).to eq 11 }
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

      it { expect(subject).not_to be_new_entry }
    end

    context "new entry" do
      let!(:message) {
        FactoryGirl.create(:message,
                           created_at: current_time - 24.hours + 1.second,
                           updated_at: current_time - 24.hours + 1.second)
      }

      it { expect(subject).to be_new_entry }
    end
  end

  describe "search_hit?" do
    let!(:message) { Message.new(title: "title", author: "author", content: "content") }

    context "hit" do
      it { expect(message.search_hit?("title")).to be_truthy }
      it { expect(message.search_hit?(" title")).to be_truthy }
      it { expect(message.search_hit?("title ")).to be_truthy }
      it { expect(message.search_hit?("t i t l e")).to be_truthy }
      it { expect(message.search_hit?("hello  title  test")).to be_truthy }
      it { expect(message.search_hit?("author")).to be_truthy }
      it { expect(message.search_hit?("content")).to be_truthy }
      it { expect(message.search_hit?("content ")).to be_truthy }
      it { expect(message.search_hit?("title author content")).to be_truthy }
    end

    context "not hit" do
      it { expect(message.search_hit?("")).not_to be_truthy }
      it { expect(message.search_hit?("titles")).not_to be_truthy }
      it { expect(message.search_hit?("authors")).not_to be_truthy }
      it { expect(message.search_hit?("contents")).not_to be_truthy }
    end
  end

  describe "log_request" do
    let!(:updated_at) { Time.now - 1.minute }
    let!(:message) { FactoryGirl.create(:message, updated_at: updated_at) }

    before do
      request = double(ActionDispatch::Request)
      request.should_receive(:remote_addr).and_return('127.0.0.1')
      request.should_receive(:user_agent).and_return('rspec')

      message.log_request(request)
    end

    it { expect(message.remote_addr).to eq '127.0.0.1' }
    it { expect(message.user_agent).to eq 'rspec' }
    it {expect( message.updated_at).to be >  updated_at}
  end
end
