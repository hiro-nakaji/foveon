module MessagesHelper
  def url_for_entry(entry)
    case entry
    when Message
      message_url(entry)
    when Comment
      message_comment_url(entry.message, entry)
    end
  end
end
