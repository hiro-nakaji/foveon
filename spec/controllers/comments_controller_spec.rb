require 'spec_helper'

describe CommentsController do
  describe "new" do
    let!(:message) { FactoryGirl.create(:message_with_no_comment) }
    before do
      get :new, message_id: message.id
    end

    it { assigns[:message].should == message }
    it { assigns[:comment].should be_new_record }
    it { assigns[:comment].title.should == message.title.gsub(/^/, "Re: ")}
    it {
      content = I18n.t('entry.wrote', author: message.author) + "\n"
      content += message.content.gsub(/^/, "> ")
      assigns[:comment].content.should == content
    }

    it { response.should be_success }
    it { response.should render_template("new") }
  end
end