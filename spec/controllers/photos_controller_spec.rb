require 'spec_helper'

describe PhotosController do
  describe "show" do
    shared_examples_for "show photo" do
      it { assigns[:photo].should == photo }
      it { response.should be_success }
      it { response.should render_template("show") }
    end

    context "attached to Message" do
      let!(:photo) { FactoryGirl.create(:photo1, entry: FactoryGirl.create(:message)) }

      before do
        get :show, id: photo.id
      end

      it_should_behave_like "show photo"
    end

    context "attached to Comment" do
      let!(:comment) { FactoryGirl.create(:comment) }
      let!(:photo) { FactoryGirl.create(:photo1, entry: comment) }

      before do
        get :show, id: photo.id
      end

      it_behaves_like "show photo"
    end

    context "attached to none" do
      let!(:photo) { FactoryGirl.create(:photo1) }

      before do
        get :show, id: photo.id
      end

      it_behaves_like "show photo"
    end
  end
end
