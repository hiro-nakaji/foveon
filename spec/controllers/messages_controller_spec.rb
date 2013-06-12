require 'spec_helper'

describe MessagesController do
  describe "trees" do
    let!(:message) {FactoryGirl.create(:message)}

    before do
      get :trees
    end

    it "has one message" do
      assigns(:messages).should eq([message])
    end
  end
end