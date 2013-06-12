FactoryGirl.define do
  factory :message do
    title 'メッセージタイトル'
    author '鯖料理人'
    password 'password'
    mail 'mackerel-chef@example.com'
    homepage 'http://foveon-bbs.com'
    content "当掲示板技術的管理人の鯖料理人です。\nフォビオンセンサーを搭載したシグマ製カメラとレンズについての掲示板です。"
    remote_addr 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.65 Safari/537.31'
    user_agent '127.0.0.1'

    after(:create) do |message|
      message.comments << FactoryGirl.create(:comment1)
      message.comments << FactoryGirl.create(:comment2)
    end
  end
end
