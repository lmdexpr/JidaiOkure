JidaiOkure
==========

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

* authorization only option (-a, --auth-only)
* daemonize
* update name system
  * @screen-name update_name <name>
  * <name>(@screen-name)
  * OK: separate by space, ZENAKKU space, newline
* itiban-nori!
  * image post when update name unique word
