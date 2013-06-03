class MessagesController < ApplicationController

  before_action :find_message, only: [:show, :edit, :update, :thread]

  def new
    @message = Message.new()
    @message.build_photos_up_to_max
  end

  def create
    permitted = [:title, :author, :password, :mail, :homepage, :content,
                photos_attributes: [:title, :photo_data, :no, :photo_data_cache, :_destroy]]
    message_params = params.require(:message).permit(permitted)
    @message = Message.new(message_params)

    if @message.save
      redirect_to action: :trees
    else
      @message.build_photos_up_to_max
      render action: :new
    end
  end

  def show
  end


  def edit
    @message.build_photos_up_to_max
  end

  def update
    permitted = [:title, :author, :password, :mail, :homepage, :content,
                 photos_attributes: [:id, :title, :photo_data, :no, :photo_data_cache, :_destroy]]
    message_params = params.require(:message).permit(permitted)

    if @message.update_attributes(message_params)
      redirect_to action: :trees
    else
      @message.build_photos_up_to_max
      render action: :edit
    end
  end

  def destroy
  end

  # get
  def trees
    @messages = Message.desc.page(params[:page])
  end

  # get
  def thread
  end

  # get
  def respond
    parent = Message.find(params[:id])
    @root = parent.root
    @message = Message.new(parent: @root)
    @message.title = "Re #{parent.title}"
  end

  # post
  def respond_post
    @parent = Message.find(params[:id])
  end

  def find_message
    @message = Message.find(params[:id])
  end
end
