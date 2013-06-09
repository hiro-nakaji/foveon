xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.rss version: "2.0" do
  xml.channel do
    xml.title t('site.title')
    xml.description t('site.description')
    xml.link root_url

    for entry in @entries
      xml.item do
        xml.title entry.title
        xml.description entry.content
        xml.dc :creator, entry.author
        xml.pubDate entry.created_at.to_s(:rfc822)
        xml.link url_for_entry(entry)
        xml.guid url_for_entry(entry)
      end
    end
  end
end
