class PhotosController < ApplicationController
  before_action :find_photo, only: [:show, :edit, :update]

  def show

  end

  def find_photo
    @photo = Photo.find(params[:id])
  end
end
