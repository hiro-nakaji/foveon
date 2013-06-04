class PhotosController < ApplicationController
  before_action :find_photo, only: [:show, :edit, :update, :destroy]

  def show
  end

  private

  def find_photo
    @photo = Photo.find(params[:id])
  end
end
