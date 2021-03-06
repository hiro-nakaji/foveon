require 'spec_helper'

describe MessagesController do
  describe "new" do
    before do
      get :new
    end

    it { expect(assigns[:message]).to be_new_record }
    it { expect(assigns[:message]).to have(4).photos }
    it { expect(response).to be_success }
    it { expect(response).to render_template("new") }
  end

  describe "create" do
    context "with valid parameters" do
      let!(:params) { FactoryGirl.attributes_for(:message) }

      before do
        params[:photos_attributes] = [
          FactoryGirl.attributes_for(:photo1),
          FactoryGirl.attributes_for(:photo2)
        ]
      end

      describe "Transition" do
        it "message count should change by +1" do
          expect {
            post :create, message: params
          }.to change(Message, :count).by(1)
        end

        it "photo count should change by +2" do
          expect {
            post :create, message: params
          }.to change(Photo, :count).by(2)
        end
      end

      context "State" do
        before do
          post :create, message: params
        end

        it { expect(assigns[:message]).to be_persisted }
        it { expect(assigns[:message]).to have(2).photos }
        it { expect(response).to redirect_to(thread_message_path(assigns[:message])) }
        specify "Make in exif == 'SIGMA'" do
          expect(assigns[:message].photos[0].exif["Make"]).to eq 'SIGMA'
        end
        specify "Model in exif == 'SIGMA SD1 Merrill'" do
          expect(assigns[:message].photos[1].exif["Model"]).to eq 'SIGMA SD1 Merrill'
        end
      end
    end

    context "with invalid parameters" do
      let!(:params) { FactoryGirl.attributes_for(:invalid_message) }

      before do
        params[:photos_attributes] = [
          FactoryGirl.attributes_for(:photo1),
          FactoryGirl.attributes_for(:photo2)
        ]
      end

      describe "Transition" do
        it "message count should not change" do
          expect {
            post :create, message: params
          }.not_to change(Message, :count)
        end

        it "photo count should not change" do
          expect {
            post :create, message: params
          }.not_to change(Photo, :count)
        end
      end

      describe "State" do
        before do
          post :create, message: params
        end

        it { expect(assigns[:message]).to be_new_record }
        it { expect(assigns[:message]).to have(4).photos }
        it { expect(response).to be_success }
        it { expect(response).to render_template("new") }
      end
    end
  end

  describe "show" do
    let!(:message) { FactoryGirl.create(:message) }

    before do
      get :show, id: message.id
    end

    it { expect(assigns[:message]).to eq message }
    it { expect(response).to be_success }
    it { expect(response).to render_template("show") }
  end

  describe "edit" do
    let!(:message) { FactoryGirl.create(:message) }

    before do
      get :edit, id: message.id
    end

    it { expect(assigns[:message]).to eq message }
    it { expect(assigns[:message]).to have(4).photos }
    it { expect(response).to be_success }
    it { expect(response).to render_template("edit") }
  end

  describe "update" do
    let!(:message) { FactoryGirl.create(:message) }
    let!(:original_attrs) { FactoryGirl.attributes_for(:message).stringify_keys }

    context "with valid parameters" do
      let!(:params) { message.attributes.dup }

      before do
        params["title"] = "#{message.title} updated"
        params["password"] = original_attrs["password"]
        patch :update, id: message.id, message: params
      end

      it { expect(assigns[:message]).to eq message }
      it { expect(assigns[:message].title).to eq params["title"] }
      it { expect(response).to redirect_to(thread_message_path(message)) }
    end

    context "with invalid password" do
      let!(:params) { message.attributes.dup }

      before do
        params["title"] = "#{message.title} updated"
        params["password"] = original_attrs["password"] + "1"
        patch :update, id: message.id, message: params
      end

      it { expect(assigns[:message]).to eq message }
      it { expect(assigns[:message].errors["password"]).to be_present }
      it { expect(response).to be_success }
      it { expect(response).to render_template("edit") }
    end

    context "with invalid parameters" do
      let!(:invalid_params) { FactoryGirl.attributes_for(:invalid_message).stringify_keys }
      let!(:params) { message.attributes.dup.merge(invalid_params) }

      before do
        patch :update, id: message.id, message: params
      end

      it { expect(assigns[:message]).to eq message }
      it { expect(assigns[:message].errors).to be_present }
      it { expect(response).to be_success }
      it { expect(response).to render_template("edit") }
    end

    context "update photo" do
      let!(:message) { FactoryGirl.create(:message) }
      let!(:params) { message.attributes.dup }
      let!(:original_attrs) { FactoryGirl.attributes_for(:message).stringify_keys }
      let!(:photo1) { FactoryGirl.create(:photo1, entry: message) }
      let!(:photo2) { FactoryGirl.create(:photo2, entry: message) }

      before do
        params["password"] = original_attrs["password"]
        params[:photos_attributes] = [photo1.attributes, photo2.attributes]
        params[:photos_attributes][0]["_destroy"] = true
        params[:photos_attributes][1]["title"] = "Title updated."
      end

      describe "Transition" do
        it "photos count should change from 2 to 1" do
          expect {
            patch :update, id: message.id, message: params
          }.to change(message.photos,:count).from(2).to(1)
        end
      end

      describe "State" do
        before do
          patch :update, id: message.id, message: params
        end

        it { expect(assigns[:message]).to eq message }
        it { expect(assigns[:message].photos.first.title).to eq "Title updated." }
        it { expect(response).to redirect_to(thread_message_path(message)) }
      end
    end
  end

  describe "delete_confirm" do
    let!(:message) { FactoryGirl.create(:message) }

    before do
      get :delete_confirm, id: message.id
    end

    it { expect(assigns[:message]).to eq message }
    it { expect(response).to be_success }
    it { expect(response).to render_template("delete_confirm") }
  end

  describe "destroy" do
    context "with valid password" do
      context "with comments" do
        let!(:message) { FactoryGirl.create(:message) }
        let!(:params) { FactoryGirl.attributes_for(:message) }

        describe "Transition" do
          it "should not be destroyed" do
            expect {
              delete :destroy, id: message.id, message: params
            }.not_to change(Message, :count)
          end
        end

        describe "State" do
          before do
            delete :destroy, id: message.id, message: params
          end

          it { expect(assigns[:message].content).to eq 'Deleted.' }
          it { expect(response).to redirect_to(trees_messages_path) }
        end
      end

      context "with no comment" do
        let!(:message) { FactoryGirl.create(:message_with_no_comment) }
        let!(:params) { FactoryGirl.attributes_for(:message_with_no_comment) }

        describe "Transition" do
          it "should be destroyed" do
            expect {
              delete :destroy, id: message.id, message: params
            }.to change(Message, :count).by(-1)
          end
        end

        describe "State" do
          before do
            delete :destroy, id: message.id, message: params
          end
          it { expect(response).to redirect_to(trees_messages_path) }
        end
      end
    end

    context "with invalid password" do
      let!(:message) { FactoryGirl.create(:message_with_no_comment) }
      let!(:params) { FactoryGirl.attributes_for(:message_with_no_comment) }

      before do
        params[:password] = params[:password] + '1'
      end

      describe "Transition" do
        it "should not be destroyed" do
          expect {
            delete :destroy, id: message.id, message: params
          }.not_to change(Message, :count)
        end
      end

      context "State" do
        before do
          delete :destroy, id: message.id, message: params
        end

        it { expect(assigns[:message].errors).to be_present }
        it { expect(response).to be_success }
        it { expect(response).to render_template("delete_confirm") }
      end
    end
  end

  describe "trees" do
    shared_examples_for "get trees action with no error" do
      it { expect(response).to be_success }
      it { expect(response).to render_template("trees") }
    end

    context "with no parameter" do
      before do
        FactoryGirl.create_list(:message, Kaminari.config.default_per_page + 1)
      end

      before do
        get :trees
      end

      it "has #{Kaminari.config.default_per_page} messages" do
        expect(assigns[:messages].count).to eq Kaminari.config.default_per_page
      end
      it_behaves_like "get trees action with no error"
    end

    context "with page parameter" do
      before do
        FactoryGirl.create_list(:message, Kaminari.config.default_per_page + 1)
        get :trees, page: 2
      end

      it "has one message" do
        expect(assigns[:messages].count).to eq 1
      end
      it_behaves_like "get trees action with no error"
    end

    context "with words parameter" do
      let!(:messages) { FactoryGirl.create_list(:message, 50) }

      context "three messages including 'message'" do
        before do
          messages[0].update_attribute(:title, 'めっせーじ')
          messages[1].update_attribute(:author, 'めっせーじ')
          messages[2].update_attribute(:content, 'めっせーじ')

          get :trees, words: 'めっせーじ'
        end

        it "has three messages" do
          expect(assigns[:messages].count).to eq 3
        end
        it_behaves_like "get trees action with no error"
      end

      context "four comments including 'comment'" do
        before do
          messages[0].comments[0].update_attribute(:title, 'こめんと')
          messages[1].comments[1].update_attribute(:author, 'こめんと')
          messages[2].comments[0].update_attribute(:content, 'こめんと')
          messages[2].comments[1].update_attribute(:title, 'こめんと')

          get :trees, words: 'こめんと'
        end

        it "has three messages" do
          expect(assigns[:messages].count).to eq 3
        end
        it_behaves_like "get trees action with no error"
      end

      context "five messages and six comments including 'message/comment' " do
        before do
          messages[0].update_attribute(:title, 'めっせーじ')
          messages[1].update_attribute(:author, 'こめんと')
          messages[2].update_attribute(:content, 'こめんと')
          messages[3].update_attributes(title: 'めっせーじ', author: 'こめんと', content: "めっせーじ\nコメント")
          messages[4].comments[0].update_attribute(:title, 'めっせーじ')
          messages[5].comments[0].update_attribute(:author, 'こめんと')
          messages[6].comments[0].update_attributes(title: 'めっせーじ', author: 'こめんと', content: "めっせーじ\nコメント")
          messages[7].comments[0].update_attribute(:title, 'めっせーじ')
          messages[7].comments[1].update_attribute(:author, 'こめんと')
          messages[8].update_attribute(:content, 'めっせーじ こめんと')
          messages[8].comments[1].update_attribute(:content, ' めっせーじ こめんと')

          get :trees, words: 'めっせーじ こめんと'
        end

        it "has nine messages" do
          expect(assigns[:messages].count).to eq 9
        end
        it_behaves_like "get trees action with no error"
      end
    end

    context "with page and words parameter" do
      message_all   = 55
      page          = (message_all.to_f / Kaminari.config.default_per_page).ceil
      message_count = message_all % Kaminari.config.default_per_page

      let!(:messages) { FactoryGirl.create_list(:message, message_all) }

      before do
        get :trees, page: page, words: "#{messages[0].title} #{messages[0].author}"
      end

      it "has #{message_count} messages" do
        expect(assigns[:messages].count).to eq message_count
      end
      it_behaves_like "get trees action with no error"
    end
  end

  describe "feed" do
    let!(:entries) {
      FactoryGirl.create_list(:message, 50).concat(Comment.all).sample(10)
    }

    before do
      entries.each_with_index do |entry, index|
        entry.update_attribute(:created_at, Time.now + (index + 1).hours)
      end
      get :feed, format: :xml
    end

    it { expect(assigns[:entries].count).to eq 10 }
    it { expect(assigns[:entries]).to eq entries.reverse}
  end

  describe "thread" do
    let!(:message) { FactoryGirl.create(:message) }

    before do
      get :thread, id: message.id
    end

    it { expect(assigns[:message]).to eq message }
    it { expect(response).to be_success }
    it { expect(response).to render_template("thread") }
  end

  describe "load_cookies" do
    let!(:params) { FactoryGirl.attributes_for(:message) }

    before do
      post :create, message: params
      get :new
    end

    it { expect(assigns[:message]).to be_new_record }
    it { expect(assigns[:message]).to have(4).photos }
    it { expect(response).to be_success }
    it { expect(response).to render_template("new") }
    Message.cookie_keys.each do | key |
      it { expect(assigns[:message][key]).to eq params[key] }
    end
  end

  describe "save_cookies" do
    let!(:params) { FactoryGirl.attributes_for(:message) }

    context "with valid parameters" do
      before do
        post :create, message: params
      end

      it { expect(assigns[:message]).to be_persisted }
      it { expect(response).to redirect_to(thread_message_path(assigns[:message])) }

      Message.cookie_keys.each do | key |
        it { expect(cookies.signed[key]).to eq params[key] }
      end
    end

    context "with invalid parameters" do
      before do
        params[:password] = nil
        post :create, message: params
      end

      it { expect(assigns[:message]).to be_new_record }
      it { expect(assigns[:message]).to have(4).photos }
      it { expect(response).to be_success }
      it { expect(response).to render_template("new") }

      Message.cookie_keys.each do | key |
        it { expect(cookies.signed[key]).to be_nil}
      end
    end
  end
end
