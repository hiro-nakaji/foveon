class MessagesController < ApplicationController

  before_action :find_message, only: [:show, :edit, :update, :thread, :delete_confirm, :destroy]

  def new
    @message = Message.new()
    @message.build_photos_up_to_max
  end

  def create
    message_params = params.require(:message).permit(Message.permitted_create_params)
    @message = Message.new(message_params)

    if @message.save
      redirect_to thread_message_path(@message)
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
    message_params = params.require(:message).permit(Message.permitted_update_params)

    if @message.update_attributes(message_params)
      redirect_to thread_message_path(@message)
    else
      @message.build_photos_up_to_max
      render action: :edit
    end
  end

  # get
  def delete_confirm
  end

  def destroy
    message_params = params.require(:message).permit(Message.permitted_destroy_params)
    @message.assign_attributes(message_params)

    if @message.valid?
      if @message.comments.empty?
        @message.destroy
      else
        @message.update_attributes(content: 'Deleted.')
        @message.photos.destroy_all
      end
      redirect_to action: :trees
    else
      render action: :delete_confirm
    end
  end

  # get
  def trees
    @messages = Message.desc.page(params[:page])
  end

  # get
  def thread
  end

  def find_message
    @message = Message.find(params[:id])
  end
end
