package com.lmdexpr.jidaiokure

import scalaz._
import Scalaz._

import twitter4j._
import twitter4j.auth._

import java.io._

object JidaiNoOkure {
  case class Config(accToken: String, accTokenSec: String)
  object Config {
    private val cb = new ConfigurationBuilder()
    val get = cb.setOAuthConsumerKey("rdbKRAFhKZQflJ4p6TEwOnGr3")
      .setOAuthConsumerSecret("dSVf2Urw9sDsCMnPliCowddvDYFRQtNcQQdvW5vVX56h73u49T")
      .setOAuthAccessToken(accToken)
      .setOAuthAccessTokenSecret(accTokenSec)
      .build()
  }

  def run = {
    // parse args using scopt

    val f = new File(".authed")
    Config.tupled(if (f.exists()) configGet_by(f) else auth(f))
    f.close


    val listener: StatusListener = new StatusListener {
      def onStatus(status: Status) = {
      }
      def onDeletionNotice(s: StatusDeletionNotice) = {}
      def onTrackLimitationNotice(numberOfLimitedStatuses: Int) = {}
      def onException(ex: Exception) = ex.printStackTrace()
      def onScrubGeo(userId: Long, upToStatusId: Long) = {}
    }

    val stream = new TwitterStream(Config.get).getInstance

    stream.addListener(listener)
    stream.user()
  }

  trait JidaiOkure {
    def target
    def parse
    def run
  }

  class UpdateName extends JidaiOkure {
  }

  class ItibanNori extends JidaiOkure {
  }

  class Kiresou extends JidaiOkure {
  }

  class JikoSyoukai extends JidaiOkure {
  }

  class Noboru extends JidaiOkure {
  }
}
