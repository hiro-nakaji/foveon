class MessagesController < ApplicationController

  before_action :find_message, only: [:show, :edit, :update, :thread, :delete_confirm, :destroy]
  after_action :save_cookies, only: [:create, :update]

  def new
    @message = Message.new(load_cookies)
    @message.build_photos_up_to_max
  end

  def create
    message_params = params.require(:message).permit(Message.permitted_create_params)
    @message = Message.new(message_params)

    if @message.save
      @message.log_request(request)
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
      @message.log_request(request)
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
        @message.log_request(request)
        @message.photos.destroy_all
      end
      redirect_to action: :trees
    else
      render action: :delete_confirm
    end
  end

  # get
  def trees
    if params[:words].present?
      @messages = Message.search_from_input(params[:words]).desc.page(params[:page])
    else
      @messages = Message.desc.page(params[:page])
    end
  end

  # get
  def feed
    messages = Message.desc.limit(10)
    comments = Comment.desc.limit(10)
    entries = messages.concat(comments).sort do |a, b|
      a.created_at <=> b.created_at
    end
    @entries = entries.reverse.slice(0, 10)

    render :layout => false
  end

  # get
  def thread
  end

  private

  def find_message
    @message = Message.find(params[:id])
  end

  def load_cookies
    data = Hash.new
    Message.cookie_keys.map do |key|
      data[key] = cookies.signed[key]
    end

    data
  end

  def save_cookies
    return unless response.status == Rack::Utils.status_code(:found)
    
    Message.cookie_keys.each do |key|
      cookies.signed[key] = {value: @message[key], path: root_path, expires: 1.year.from_now}
    end
  end
end
