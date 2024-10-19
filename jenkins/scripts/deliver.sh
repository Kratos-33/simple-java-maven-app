#!/usr/bin/env bash

echo 'The following Maven command installs your Maven-built Java application'
echo 'into the local Maven repository, which will ultimately be stored in'
echo 'Jenkins''s local Maven repository (and the "maven-repository" Docker data'
echo 'volume).'
set -x
# Adding clean to ensure fresh build
mvn clean jar:jar install:install help:evaluate -Dexpression=project.name
BUILD_STATUS=$?
set +x

if [ $BUILD_STATUS -ne 0 ]; then
  echo "Maven build failed. Exiting."
  exit 1
fi

echo 'The following command extracts the value of the <name/> element'
echo 'within <project/> of your Java/Maven project''s "pom.xml" file.'
set -x
NAME=$(mvn -q -DforceStdout help:evaluate -Dexpression=project.name)
set +x

echo 'The following command behaves similarly to the previous one but'
echo 'extracts the value of the <version/> element within <project/> instead.'
set -x
VERSION=$(mvn -q -DforceStdout help:evaluate -Dexpression=project.version)
set +x

JAR_FILE="target/${NAME}-${VERSION}.jar"

if [ ! -f "$JAR_FILE" ]; then
  echo "Error: JAR file $JAR_FILE not found. Please check the build output."
  exit 1
fi

echo 'The following command runs and outputs the execution of your Java'
echo 'application (which Jenkins built using Maven) to the Jenkins UI.'
set -x
java -jar "$JAR_FILE"

