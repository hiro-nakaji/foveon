require 'spec_helper'

describe CommentsController do
  describe "new" do
    let!(:message) { FactoryGirl.create(:message_with_no_comment) }
    before do
      get :new, message_id: message.id
    end

    it { assigns[:message].should == message }
    it { assigns[:comment].should be_new_record }
    it { assigns[:comment].title.should == message.title.gsub(/^/, "Re: ") }
    it {
      content = I18n.t('entry.wrote', author: message.author) + "\n"
      content += message.content.gsub(/^/, "> ")
      assigns[:comment].content.should == content
    }

    it { response.should be_success }
    it { response.should render_template("new") }
  end

  describe "create" do
    let!(:message) { FactoryGirl.create(:message_with_no_comment) }

    context "with valid parameters" do
      let!(:params) { FactoryGirl.attributes_for(:valid_comment) }
      before do
        params[:photos_attributes] = [
          FactoryGirl.attributes_for(:photo1),
          FactoryGirl.attributes_for(:photo2)
        ]
      end

      context "expect" do
        it "comments count should change by +1" do
          expect {
            post :create, message_id: message.id, comment: params
          }.to change(message.comments, :count).by(1)
        end

        it "photo count should change by +2" do
          expect {
            post :create, message_id: message.id, comment: params
          }.to change(Photo, :count).by(2)
        end
      end

      context "should" do
        before do
          post :create, message_id: message.id, comment: params
        end

        it { assigns[:message].should == message }
        it { assigns[:comment].should be_persisted }
        it { assigns[:comment].should have(2).photos }
        it {
          redirect_path = thread_message_path(message, anchor: assigns[:comment].id)
          response.should redirect_to(redirect_path)
        }
      end
    end

    context "with invalid parameters" do
      let!(:message) { FactoryGirl.create(:message_with_no_comment) }
      let!(:params) { FactoryGirl.attributes_for(:invalid_comment) }

      before do
        params[:photos_attributes] = [
          FactoryGirl.attributes_for(:photo1),
          FactoryGirl.attributes_for(:photo2)
        ]
      end

      context "expect" do
        it "comments count should not change" do
          expect {
            post :create, message_id: message.id, comment: params
          }.to_not change(message.comments, :count)
        end

        it "photo count should not change" do
          expect {
            post :create, message_id: message.id, comment: params
          }.to_not change(Photo, :count)
        end
      end

      context "should" do
        before do
          post :create, message_id: message.id, comment: params
        end

        it { assigns[:message].should == message }
        it { assigns[:comment].should be_new_record }
        it { assigns[:comment].should have(4).photos }
        it { response.should be_success }
        it { response.should render_template("new") }
      end
    end
  end

  describe "show" do
    let!(:message) { FactoryGirl.create(:message) }
    let!(:comment) { message.comments.first }

    before do
      get :show, message_id: message.id, id: comment.id
    end

    it { assigns[:message].should == message }
    it { assigns[:comment].should == comment }
    it { response.should be_success }
    it { response.should render_template("show") }
  end
end