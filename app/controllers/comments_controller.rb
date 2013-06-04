class CommentsController < ApplicationController

  before_action :find_message
  before_action :find_comment, only: [:show, :edit, :update, :delete_confirm, :destroy]

  def new
    @comment = @message.comments.build
    @message.reply(@comment)
    @comment.build_photos_up_to_max
  end

  def reply
    target = @message.comments.find(params[:id])
    @comment = @message.comments.build
    target.reply(@comment)
    @comment.build_photos_up_to_max

    render action: :new
  end

  def create
    comment_params = params.require(:comment).permit(Comment.permitted_create_params)
    @comment = @message.comments.build(comment_params)

    if @comment.save
      redirect_to thread_message_path(@message)
    else
      @comment.build_photos_up_to_max
      render action: :new
    end
  end

  def show
  end

  def edit
    @comment.build_photos_up_to_max
  end

  def update
    comment_params = params.require(:comment).permit(Comment.permitted_update_params)

    if @comment.update_attributes(comment_params)
      redirect_to thread_message_path(@message)
    else
      @comment.build_photos_up_to_max
      render action: :edit
    end

  end

  def delete_confirm
  end

  def destroy
    comment_params = params.require(:comment).permit(Comment.permitted_destroy_params)
    @comment.assign_attributes(comment_params)
    if @comment.valid?
      @comment.destroy
      redirect_to thread_message_path(@message)
    else
      render action: :delete_confirm
    end
  end

  private

  def find_message
    @message =  Message.find(params[:message_id])
  end

  def find_comment
    @comment =  @message.comments.find(params[:id])
  end
end
