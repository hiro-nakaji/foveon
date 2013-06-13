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
    let!(:message) { FactoryGirl.create(:message_with_no_comment) }
    let!(:comment) { FactoryGirl.create(:comment, message: message) }

    before do
      get :show, message_id: message.id, id: comment.id
    end

    it { assigns[:message].should == message }
    it { assigns[:comment].should == comment }
    it { response.should be_success }
    it { response.should render_template("show") }
  end

  describe "edit" do
    let!(:message) { FactoryGirl.create(:message_with_no_comment) }
    let!(:comment) { FactoryGirl.create(:comment, message: message) }

    before do
      get :edit, message_id: message.id, id: comment.id
    end

    it { assigns[:message].should == message }
    it { assigns[:comment].should == comment }
    it { assigns[:comment].should have(4).photos }
    it { response.should be_success }
    it { response.should render_template("edit") }
  end

  describe "update" do
    let!(:message) { FactoryGirl.create(:message_with_no_comment) }
    let!(:comment) { FactoryGirl.create(:comment, message: message) }
    let!(:original_attrs) { FactoryGirl.attributes_for(:comment).stringify_keys }

    context "with valid parameters" do
      let!(:params) { comment.attributes.dup }

      before do
        params["title"]    = "#{comment.title} updated"
        params["password"] = original_attrs["password"]
        put :update, message_id: message.id, id: comment.id, comment: params
      end

      it { assigns[:message].should == message }
      it { assigns[:comment].should == comment }
      it { assigns[:comment].title.should == params["title"] }
      it {
        redirect_path = thread_message_path(message, anchor: comment.id)
        response.should redirect_to(redirect_path)
      }
    end

    context "with invalid password" do
      let!(:params) { comment.attributes.dup }

      before do
        params["title"]    = "#{comment.title} updated"
        params["password"] = original_attrs["password"] + "1"
        put :update, message_id: message.id, id: comment.id, comment: params
      end

      it { assigns[:message].should == message }
      it { assigns[:comment].should == comment }
      it { assigns[:comment].errors["password"].should be_present }
      it { response.should be_success }
      it { response.should render_template("edit") }
    end

    context "with invalid parameters" do
      let!(:invalid_params) { FactoryGirl.attributes_for(:invalid_message).stringify_keys }
      let!(:params) { comment.attributes.dup.merge(invalid_params) }

      before do
        put :update, message_id: message.id, id: comment.id, comment: params
      end

      it { assigns[:message].should == message }
      it { assigns[:comment].should == comment }
      it { assigns[:comment].errors.should be_present }
      it { response.should be_success }
      it { response.should render_template("edit") }
    end

    context "update photo" do
      let!(:message) { FactoryGirl.create(:message_with_no_comment) }
      let!(:comment) { FactoryGirl.create(:comment, message: message) }
      let!(:params) { comment.attributes.dup }
      let!(:original_attrs) { FactoryGirl.attributes_for(:comment).stringify_keys }
      let!(:photo1) { FactoryGirl.create(:photo1) }
      let!(:photo2) { FactoryGirl.create(:photo2) }

      before do
        comment.photos = [photo1, photo2]
        params["password"] = original_attrs["password"]
        params[:photos_attributes] = [photo1.attributes, photo2.attributes]
        params[:photos_attributes][0]["_destroy"] = true
        params[:photos_attributes][1]["title"] = "Title updated."
      end

      context "expect" do
        it "photos count should change from 2 to 1" do
          expect {
            put :update, message_id: message.id, id: comment.id, comment: params
          }.to change(comment.photos,:count).from(2).to(1)
        end
      end

      context "should" do
        before do
          put :update, message_id: message.id, id: comment.id, comment: params
        end

        it { assigns[:message].should == message }
        it { assigns[:comment].should == comment }
        it { assigns[:comment].photos.first.title.should == "Title updated." }
        it {
          redirect_path = thread_message_path(message, anchor: comment.id)
          response.should redirect_to(redirect_path)
        }
      end
    end
  end

  describe "delete_confirm" do
    let!(:message) { FactoryGirl.create(:message_with_no_comment) }
    let!(:comment) { FactoryGirl.create(:comment, message: message) }

    before do
      get :delete_confirm, message_id: message.id, id: comment.id
    end

    it { assigns[:message].should == message }
    it { assigns[:comment].should == comment }
    it { response.should be_success }
    it { response.should render_template("delete_confirm") }
  end

  describe "destroy" do
    let!(:message) { FactoryGirl.create(:message_with_no_comment) }
    let!(:comment) { FactoryGirl.create(:comment, message: message) }
    let!(:params) { FactoryGirl.attributes_for(:comment) }

    context "with valid password" do
      context "expect" do
        it "should be destroyed" do
          expect {
            delete :destroy, message_id: message.id, id: comment.id, comment: params
          }.to change(message.comments, :count).by(-1)
        end
      end

      context "should" do
        before do
          delete :destroy, message_id: message.id, id: comment.id, comment: params
        end

        it { response.should redirect_to(thread_message_path(message)) }
      end
    end

    context "with invalid password" do
      before do
        params[:password] = params[:password] + '1'
      end

      context "expect" do
        it "should not be destroyed" do
          expect {
            delete :destroy, message_id: message.id, id: comment.id, comment: params
          }.not_to change(message.comments, :count)
        end
      end

      context "should" do
        before do
          delete :destroy, message_id: message.id, id: comment.id, comment: params
        end

        it { response.should be_success }
        it { response.should render_template("delete_confirm") }
      end
    end
  end
end