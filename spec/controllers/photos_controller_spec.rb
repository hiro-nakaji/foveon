require 'spec_helper'

describe PhotosController do
  describe "show" do
    shared_examples_for "show photo" do
      it { expect(assigns[:photo]).to eq photo }
      it { expect(response).to be_success }
      it { expect(response).to render_template("show") }
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
  end
end
