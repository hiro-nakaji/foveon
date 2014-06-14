class Admin::MessagesController < Admin::ApplicationController
  def index
    @messages = Message.desc.page(params[:page]).per(Settings.admin.messages.per_page)
  end

  def bulk_destroy
    ActiveRecord::Base.transaction do
      Message.where(id: params[:messages]).destroy_all
    end

    redirect_to admin_messages_path
  end
end
