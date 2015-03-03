organization := "com.lmdexpr"

scalaVersion := "2.11.5"

name         := "JidaiOkure NEWGENERATION"

version      := "0.0.1"

libraryDependencies ++= Seq(
  "org.twitter4j" % "twitter4j-core" % "4.0.2",
  "org.scalaz"    % "scalaz-core"    % "7.1.1"
)

scalaOptions ++= Seq("-deprecation", "-encoding", "UTF-8")

fork := true

mainClass in Compile := Some("com.lmdexpr.Main")
