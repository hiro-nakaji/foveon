require 'spec_helper'

describe MessagesController do
  describe "new" do
    before do
      get :new
    end

    it { assigns[:message].should be_an_instance_of Message }
    it { assigns[:message].should have(4).photos }
    it { response.should be_success }
    it { response.should render_template("new") }
    it { flash[:notice].should be_nil }
    it { flash[:error].should be_nil }
  end

  describe "create" do
    context "with valid parameters" do
      let!(:params) { FactoryGirl.attributes_for(:message) }

      before do
        params[:photos_attributes] = [
          FactoryGirl.attributes_for(:photo1),
          FactoryGirl.attributes_for(:photo2)
        ]
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

    context "with invalid parameters" do
      let!(:params) { FactoryGirl.attributes_for(:invalid_message) }

      before do
        post :create, message: params
      end

      it { assigns[:message].should be_new_record }
      it { assigns[:message].should have(4).photos }
      it { response.should be_success }
      it { response.should render_template("new") }
    end
  end

  describe "show" do
    let!(:message) { FactoryGirl.create(:message) }

    before do
      get :show, id: message.id
    end

    it { assigns[:message].should_not be_nil }
    it { response.should be_success }
    it { response.should render_template("show") }
  end

  describe "trees" do
    shared_examples_for "get trees action with no error" do
      it { response.should be_success }
      it { response.should render_template("trees") }
      it { flash[:notice].should be_nil }
      it { flash[:error].should be_nil }
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
end
