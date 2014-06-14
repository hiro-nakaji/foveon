class Admin::CommentsController < Admin::ApplicationController
  def index
    @comments = Comment.desc.page(params[:page]).per(Settings.admin.messages.per_page)
  end

  def bulk_destroy
    ActiveRecord::Base.transaction do
      Comment.where(id: params[:comments]).destroy_all
    end

    redirect_to admin_comments_path(page: params[:page])
  end
end
