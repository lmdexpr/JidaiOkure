JidaiOkure
==========

[![Join the chat at https://gitter.im/lmdexpr/JidaiOkure](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/lmdexpr/JidaiOkure?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

今時twitterAPIなんて流行らないよ

## Dependency

* twitter
* tweetstream
* oauth

## How to Running

``` bash
gem install twitter tweetstream oauth
./JidaiOkure.rb
```

## Functions

* authorization only option. (-a, --auth-only)
* daemonize.
* update name system.
  * @screen-name update_name <name>
  * <name>(@screen-name)
  * OK: separate by space, ZENKAKU space, newline.
* itiban-nori!
  * image post when update name unique word.
* kireru
  * When found your tweet for dis my name, I angry.
* JikoSyoukai
  * @screen-name whoare(u|you)?
  * @screen-name 誰?
  * reply my name.
