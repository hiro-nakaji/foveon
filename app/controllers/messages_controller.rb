class MessagesController < ApplicationController

  def new
    @message = Message.new()
  end

  def create
    @message = Message.new(params[:message])

    if @message.save
      redirect_to action: :trees
    else
      render action: :new
    end
  end

  def show
    @message = Message.find(params[:id])
  end


  def edit
  end

  def update
  end

  def destroy
  end

  # get
  def trees
    @messages = Message.desc.page(params[:page])
  end

  # get
  def thread
    @message = Message.find(params[:id])
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
end
