FactoryGirl.define do
  factory :comment do
    title 'Re: メッセージタイトル'
    author '鯖料理人'
    password 'password'
    mail 'mackerel-chef@example.com'
    homepage 'http://foveon-bbs.com'
    content "フォビオン掲示板と画像掲示板を統合し、装いを新たにオープンいたします。"
    remote_addr 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.65 Safari/537.31'
    user_agent '192.168.1.1'
  end

  factory :valid_comment, class: Comment do
    title 'Re: メッセージタイトル'
    password 'password'
    author 'さばりょうりにんß'
    content "おめでとうございます！\n> フォビオン掲示板と画像掲示板を統合し、装いを新たにオープンいたします。"
  end

  factory :invalid_comment, class: Comment do
    title nil
    author nil
    password nil
    content nil
  end

  factory :comment1, class: Comment do
    title 'Re: メッセージタイトル'
    author '鯖料理人'
    password 'password'
    mail 'mackerel-chef@example.com'
    homepage 'http://foveon-bbs.com'
    content "フォビオン掲示板と画像掲示板を統合し、装いを新たにオープンいたします。"
    remote_addr 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.65 Safari/537.31'
    user_agent '192.168.1.1'
  end

  factory :comment2, class: Comment do
    title 'Re: Re: メッセージタイトル'
    author '鯖料理人'
    password 'password'
    mail 'mackerel-chef@example.com'
    homepage 'http://foveon-bbs.com'
    content "maro様、Outliner様をはじめ、ご協力いただいた皆様に感謝いたします。"
    remote_addr 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.65 Safari/537.31'
    user_agent '192.168.1.1'
  end
end
