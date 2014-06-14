require 'spec_helper'

describe CommentsController do
  describe "new" do
    let!(:message) { FactoryGirl.create(:message_with_no_comment) }
    before do
      get :new, message_id: message.id
    end

    it { expect(assigns[:message]).to eq message }
    it { expect(assigns[:comment]).to be_new_record }
    it { expect(assigns[:comment]).to have(4).photos }
    it { expect(assigns[:comment].title).to eq message.title.gsub(/^/, "Re: ") }
    it {
      content = I18n.t('entry.wrote', author: message.author) + "\n"
      content += message.content.gsub(/^/, "> ")
      expect(assigns[:comment].content).to eq content
    }
    it { expect(response).to be_success }
    it { expect(response).to render_template("new") }
  end

  describe "reply" do
    let!(:comment) { FactoryGirl.create(:comment) }

    before do
      get :reply, message_id: comment.message.id, id: comment.id
    end

    it { expect(assigns[:message]).to eq comment.message }
    it { expect(assigns[:comment]).to be_new_record }
    it { expect(assigns[:comment]).to have(4).photos }
    it { expect(assigns[:comment].title).to eq comment.title.gsub(/^/, "Re: ") }
    it {
      content = I18n.t('entry.wrote', author: comment.author) + "\n"
      content += comment.content.gsub(/^/, "> ")
      expect(assigns[:comment].content).to eq content
    }
    it { expect(response).to be_success }
    it { expect(response).to render_template("new") }
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

      describe "Transition" do
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

      describe "State" do
        before do
          post :create, message_id: message.id, comment: params
        end

        it { expect(assigns[:message]).to eq message }
        it { expect(assigns[:comment]).to be_persisted }
        it { expect(assigns[:comment]).to have(2).photos }
        it {
          redirect_path = thread_message_path(message, anchor: assigns[:comment].id)
          expect(response).to redirect_to(redirect_path)
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

      describe "Transition" do
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

      describe "State" do
        before do
          post :create, message_id: message.id, comment: params
        end

        it { expect(assigns[:message]).to eq message }
        it { expect(assigns[:comment]).to be_new_record }
        it { expect(assigns[:comment]).to have(4).photos }
        it { expect(response).to be_success }
        it { expect(response).to render_template("new") }
      end
    end
  end

  describe "show" do
    let!(:comment) { FactoryGirl.create(:comment) }

    before do
      get :show, message_id: comment.message.id, id: comment.id
    end

    it { expect(assigns[:message]).to eq comment.message }
    it { expect(assigns[:comment]).to eq comment }
    it { expect(response).to be_success }
    it { expect(response).to render_template("show") }
  end

  describe "edit" do
    let!(:comment) { FactoryGirl.create(:comment) }

    before do
      get :edit, message_id: comment.message.id, id: comment.id
    end

    it { expect(assigns[:message]).to eq comment.message }
    it { expect(assigns[:comment]).to eq comment }
    it { expect(assigns[:comment]).to have(4).photos }
    it { expect(response).to be_success }
    it { expect(response).to render_template("edit") }
  end

  describe "update" do
    let!(:comment) { FactoryGirl.create(:comment) }
    let!(:original_attrs) { FactoryGirl.attributes_for(:comment).stringify_keys }

    context "with valid parameters" do
      let!(:params) { comment.attributes.dup }

      before do
        params["title"]    = "#{comment.title} updated"
        params["password"] = original_attrs["password"]
        patch :update, message_id: comment.message.id, id: comment.id, comment: params
      end

      it { expect(assigns[:message]).to eq comment.message }
      it { expect(assigns[:comment]).to eq comment }
      it { expect(assigns[:comment].title).to eq params["title"] }
      it {
        expect(response).to redirect_to(thread_message_path(comment.message, anchor: comment.id))
      }
    end

    context "with invalid password" do
      let!(:params) { comment.attributes.dup }

      before do
        params["title"]    = "#{comment.title} updated"
        params["password"] = original_attrs["password"] + "1"
        patch :update, message_id: comment.message.id, id: comment.id, comment: params
      end

      it { expect(assigns[:message]).to eq comment.message }
      it { expect(assigns[:comment]).to eq comment }
      it { expect(assigns[:comment].errors["password"]).to be_present }
      it { expect(response).to be_success }
      it { expect(response).to render_template("edit") }
    end

    context "with invalid parameters" do
      let!(:invalid_params) { FactoryGirl.attributes_for(:invalid_comment).stringify_keys }
      let!(:params) { comment.attributes.dup.merge(invalid_params) }

      before do
        patch :update, message_id: comment.message.id, id: comment.id, comment: params
      end

      it { expect(assigns[:message]).to eq comment.message }
      it { expect(assigns[:comment]).to eq comment }
      it { expect(assigns[:comment].errors).to be_present }
      it { expect(response).to be_success }
      it { expect(response).to render_template("edit") }
    end

    context "update photo" do
      let!(:comment) { FactoryGirl.create(:comment) }
      let!(:params) { comment.attributes.dup }
      let!(:original_attrs) { FactoryGirl.attributes_for(:comment).stringify_keys }
      let!(:photo1) { FactoryGirl.create(:photo1, entry: comment) }
      let!(:photo2) { FactoryGirl.create(:photo2, entry: comment) }

      before do
        params["password"]                        = original_attrs["password"]
        params[:photos_attributes]                = [photo1.attributes, photo2.attributes]
        params[:photos_attributes][0]["_destroy"] = true
        params[:photos_attributes][1]["title"]    = "Title updated."
      end

      describe "Transition" do
        it "photos count should change from 2 to 1" do
          expect {
            patch :update, message_id: comment.message.id, id: comment.id, comment: params
          }.to change(comment.photos, :count).from(2).to(1)
        end
      end

      context "State" do
        before do
          patch :update, message_id: comment.message.id, id: comment.id, comment: params
        end

        it { expect(assigns[:message]).to eq comment.message }
        it { expect(assigns[:comment]).to eq comment }
        it { expect(assigns[:comment].photos.first.title).to eq "Title updated." }
        it {
          expect(response).to redirect_to(thread_message_path(comment.message, anchor: comment.id))
        }
      end
    end
  end

  describe "delete_confirm" do
    let!(:comment) { FactoryGirl.create(:comment) }

    before do
      get :delete_confirm, message_id: comment.message.id, id: comment.id
    end

    it { expect(assigns[:message]).to eq comment.message }
    it { expect(assigns[:comment]).to eq comment }
    it { expect(response).to be_success }
    it { expect(response).to render_template("delete_confirm") }
  end

  describe "destroy" do
    let!(:comment) { FactoryGirl.create(:comment) }
    let!(:message) { comment.message }
    let!(:params) { FactoryGirl.attributes_for(:comment) }

    context "with valid password" do
      context "Transition" do
        it "should be destroyed" do
          expect {
            delete :destroy, message_id: message.id, id: comment.id, comment: params
          }.to change(message.comments, :count).by(-1)
        end
      end

      context "State" do
        before do
          delete :destroy, message_id: message.id, id: comment.id, comment: params
        end

        it { expect(response).to redirect_to(thread_message_path(message)) }
      end
    end

    context "with invalid password" do
      before do
        params[:password] = params[:password] + '1'
      end

      describe "Transition" do
        it "should not be destroyed" do
          expect {
            delete :destroy, message_id: message.id, id: comment.id, comment: params
          }.not_to change(message.comments, :count)
        end
      end

      describe "State" do
        before do
          delete :destroy, message_id: message.id, id: comment.id, comment: params
        end

        it { expect(assigns[:comment].errors).to be_present }
        it { expect(response).to be_success }
        it { expect(response).to render_template("delete_confirm") }
      end
    end
  end

  describe "load_cookies" do
    let!(:message) { FactoryGirl.create(:message_with_no_comment) }
    let!(:params) { FactoryGirl.attributes_for(:comment) }

    before do
      post :create, message_id: message.id, comment: params
      get :new, message_id: message.id
    end

    it { expect(assigns[:comment]).to be_new_record }
    it { expect(assigns[:comment]).to have(4).photos }
    it { expect(response).to be_success }
    it { expect(response).to render_template("new") }

    Comment.cookie_keys.each do |key|
      it { expect(assigns[:comment][key]).to eq message[key] }
    end
  end

  describe "save_cookies" do
    let!(:message) { FactoryGirl.create(:message_with_no_comment) }
    let!(:params) { FactoryGirl.attributes_for(:comment) }

    context "with valid parameters" do
      before do
        post :create, message_id: message.id, comment: params
      end

      it { expect(assigns[:comment]).to be_persisted }
      it {
        expect(response).to redirect_to(thread_message_path(message, anchor: assigns[:comment].id))
      }

      Comment.cookie_keys.each do | key |
        it { expect(cookies.signed[key]).to eq params[key]}
      end
    end

    context "with invalid parameters" do
      before do
        params[:password] = nil
        post :create, message_id: message.id, comment: params
      end

      it { expect(assigns[:comment]).to be_new_record }
      it { expect(assigns[:comment]).to have(4).photos }
      it { expect(response).to be_success }
      it { expect(response).to render_template("new") }

      Comment.cookie_keys.each do | key |
        it { expect(cookies.signed[key]).to be_nil}
      end
    end
  end
end