name := "JidaiOkure NEWGENERATION"

organization := "com.lmdexpr"

version := "0.0.1-M1"

scalaVersion := "2.11.1"

scalacOptions := Seq(
  "-Xfatal-warnings", "-deprecation", "-feature", "-unchecked", "-encoding", "UTF-8"
)

libraryDependencies ++= Seq(
  "org.twitter4j" % "twitter4j-core" % "4.0.2",
  "com.github.scopt" % "scopt" % "3.3.0",
  "org.scalaz"    % "scalaz-core"    % "7.1.1"
)

resolvers += Resolver.sonatypeRepo("public")

testOptions in Test += Tests.Argument(TestFrameworks.ScalaTest, "-oD")
