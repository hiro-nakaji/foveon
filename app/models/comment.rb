class Comment < ActiveRecord::Base
  include Entry
  extend EntryExtend

  belongs_to :message

  validates :message_id, presence: true

  def reply_to(entry)
    raise ArgumentError, "#{entry} does not include Entry" unless entry.kind_of?(Entry)

    self.title = entry.title.gsub(/^/, "Re: ")
    self.content = I18n.t('entry.wrote', author: entry.author) + "\n"
    self.content += entry.content.gsub(/^/, "> ")
  end
end
