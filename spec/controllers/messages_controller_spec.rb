require 'spec_helper'

describe MessagesController do
  describe "new" do
    before do
      get :new
    end

    it { assigns[:message].should be_new_record }
    it { assigns[:message].should have(4).photos }
    it { response.should be_success }
    it { response.should render_template("new") }
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

      context "expect" do
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

      context "should" do
        before do
          post :create, message: params
        end

        it { assigns[:message].should be_persisted }
        it { assigns[:message].should have(2).photos }
        it { response.should redirect_to(thread_message_path(assigns[:message])) }
        it "Make in exif == 'SIGMA'" do
          assigns[:message].photos[0].exif["Make"].should == 'SIGMA'
        end
        it "Model in exif == 'SIGMA SD1 Merrill'" do
          assigns[:message].photos[1].exif["Model"].should == 'SIGMA SD1 Merrill'
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

      context "expect" do
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

      context "should" do
        before do
          post :create, message: params
        end

        it { assigns[:message].should be_new_record }
        it { assigns[:message].should have(4).photos }
        it { response.should be_success }
        it { response.should render_template("new") }
      end
    end
  end

  describe "show" do
    let!(:message) { FactoryGirl.create(:message) }

    before do
      get :show, id: message.id
    end

    it { assigns[:message].should == message }
    it { response.should be_success }
    it { response.should render_template("show") }
  end

  describe "edit" do
    let!(:message) { FactoryGirl.create(:message) }

    before do
      get :edit, id: message.id
    end

    it { assigns[:message].should == message }
    it { assigns[:message].should have(4).photos }
    it { response.should be_success }
    it { response.should render_template("edit") }
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

      it { assigns[:message].should == message }
      it { assigns[:message].title.should == params["title"] }
      it { response.should redirect_to(thread_message_path(message)) }
    end

    context "with invalid password" do
      let!(:params) { message.attributes.dup }

      before do
        params["title"] = "#{message.title} updated"
        params["password"] = original_attrs["password"] + "1"
        patch :update, id: message.id, message: params
      end

      it { assigns[:message].should == message }
      it { assigns[:message].errors["password"].should be_present }
      it { response.should be_success }
      it { response.should render_template("edit") }
    end

    context "with invalid parameters" do
      let!(:invalid_params) { FactoryGirl.attributes_for(:invalid_message).stringify_keys }
      let!(:params) { message.attributes.dup.merge(invalid_params) }

      before do
        patch :update, id: message.id, message: params
      end

      it { assigns[:message].should == message }
      it { assigns[:message].errors.should be_present }
      it { response.should be_success }
      it { response.should render_template("edit") }
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

      context "expect" do
        it "photos count should change from 2 to 1" do
          expect {
            patch :update, id: message.id, message: params
          }.to change(message.photos,:count).from(2).to(1)
        end
      end

      context "should" do
        before do
          patch :update, id: message.id, message: params
        end

        it { assigns[:message].should == message }
        it { assigns[:message].photos.first.title.should == "Title updated." }
        it { response.should redirect_to(thread_message_path(message)) }
      end
    end
  end

  describe "delete_confirm" do
    let!(:message) { FactoryGirl.create(:message) }

    before do
      get :delete_confirm, id: message.id
    end

    it { assigns[:message].should == message }
    it { response.should be_success }
    it { response.should render_template("delete_confirm") }
  end

  describe "destroy" do
    context "with valid password" do
      context "with comments" do
        let!(:message) { FactoryGirl.create(:message) }
        let!(:params) { FactoryGirl.attributes_for(:message) }

        context "expect" do
          it "should not be destroyed" do
            expect {
              delete :destroy, id: message.id, message: params
            }.not_to change(Message, :count)
          end
        end

        context "should" do
          before do
            delete :destroy, id: message.id, message: params
          end
          it { assigns[:message].content.should == 'Deleted.' }
          it { response.should redirect_to(trees_messages_path) }
        end
      end

      context "with no comment" do
        let!(:message) { FactoryGirl.create(:message_with_no_comment) }
        let!(:params) { FactoryGirl.attributes_for(:message_with_no_comment) }

        context "expect" do
          it "should be destroyed" do
            expect {
              delete :destroy, id: message.id, message: params
            }.to change(Message, :count).by(-1)
          end
        end

        context "should" do
          before do
            delete :destroy, id: message.id, message: params
          end
          it { response.should redirect_to(trees_messages_path) }
        end
      end
    end

    context "with invalid password" do
      let!(:message) { FactoryGirl.create(:message_with_no_comment) }
      let!(:params) { FactoryGirl.attributes_for(:message_with_no_comment) }

      before do
        params[:password] = params[:password] + '1'
      end

      context "expect" do
        it "should not be destroyed" do
          expect {
            delete :destroy, id: message.id, message: params
          }.not_to change(Message, :count)
        end
      end

      context "should" do
        before do
          delete :destroy, id: message.id, message: params
        end

        it { assigns[:message].errors.should be_present }
        it { response.should be_success }
        it { response.should render_template("delete_confirm") }
      end
    end
  end

  describe "trees" do
    shared_examples_for "get trees action with no error" do
      it { response.should be_success }
      it { response.should render_template("trees") }
    end

    context "with no parameter" do
      before do
        FactoryGirl.create_list(:message, Kaminari.config.default_per_page + 1)
      end

      before do
        get :trees
      end

      it "has #{Kaminari.config.default_per_page} messages" do
        assigns[:messages].count.should == Kaminari.config.default_per_page
      end
      it_behaves_like "get trees action with no error"
    end

    context "with page parameter" do
      before do
        FactoryGirl.create_list(:message, Kaminari.config.default_per_page + 1)
        get :trees, page: 2
      end

      it "has one message" do
        assigns[:messages].count.should == 1
      end
      it_behaves_like "get trees action with no error"
    end

    context "with words parameter" do
      let!(:messages) { FactoryGirl.create_list(:message, 50) }

      context "three messages including 'message'" do
        before do
          messages[0].update_attribute(:title, 'message')
          messages[1].update_attribute(:author, 'message')
          messages[2].update_attribute(:content, 'message')

          get :trees, words: 'message'
        end

        it "has three messages" do
          assigns[:messages].count.should == 3
        end
        it_behaves_like "get trees action with no error"
      end

      context "four comments including 'comment'" do
        before do
          messages[0].comments[0].update_attribute(:title, 'comment')
          messages[1].comments[1].update_attribute(:author, 'comment')
          messages[2].comments[0].update_attribute(:content, 'comment')
          messages[2].comments[1].update_attribute(:title, 'comment')

          get :trees, words: 'comment'
        end

        it "has three messages" do
          assigns[:messages].count.should == 3
        end
        it_behaves_like "get trees action with no error"
      end

      context "five messages and six comments including 'message/comment' " do
        before do
          messages[0].update_attribute(:title, 'message')
          messages[1].update_attribute(:author, 'comment')
          messages[2].update_attribute(:content, 'comment')
          messages[3].update_attributes(title: 'message', author: 'comment', content: "message\ncomment")
          messages[4].comments[0].update_attribute(:title, 'message')
          messages[5].comments[0].update_attribute(:author, 'comment')
          messages[6].comments[0].update_attributes(title: 'message', author: 'comment', content: "message\ncomment")
          messages[7].comments[0].update_attribute(:title, 'message')
          messages[7].comments[1].update_attribute(:author, 'comment')
          messages[8].update_attribute(:content, 'message comment')
          messages[8].comments[1].update_attribute(:content, 'message comment')

          get :trees, words: 'message comment'
        end

        it "has nine messages" do
          assigns[:messages].count.should == 9
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
        assigns[:messages].count.should == message_count
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

    it {assigns[:entries].count.should == 10}
    it {assigns[:entries].should == entries.reverse}
  end

  describe "thread" do
    let!(:message) { FactoryGirl.create(:message) }

    before do
      get :thread, id: message.id
    end

    it { assigns[:message].should == message }
    it { response.should be_success }
    it { response.should render_template("thread") }
  end

  describe "load_cookies" do
    let!(:params) { FactoryGirl.attributes_for(:message) }

    before do
      post :create, message: params
      get :new
    end

    it { assigns[:message].should be_new_record }
    it { assigns[:message].should have(4).photos }
    it { response.should be_success }
    it { response.should render_template("new") }
    Message.cookie_keys.each do | key |
      it {assigns[:message][key].should == params[key]}
    end
  end

  describe "save_cookies" do
    let!(:params) { FactoryGirl.attributes_for(:message) }

    context "with valid parameters" do
      before do
        post :create, message: params
      end

      it { assigns[:message].should be_persisted }
      it { response.should redirect_to(thread_message_path(assigns[:message])) }

      Message.cookie_keys.each do | key |
        it { cookies.signed[key].should ==  params[key]}
      end
    end

    context "with invalid parameters" do
      before do
        params[:password] = nil
        post :create, message: params
      end

      it { assigns[:message].should be_new_record }
      it { assigns[:message].should have(4).photos }
      it { response.should be_success }
      it { response.should render_template("new") }

      Message.cookie_keys.each do | key |
        it { cookies.signed[key].should be_nil}
      end
    end
  end
end
