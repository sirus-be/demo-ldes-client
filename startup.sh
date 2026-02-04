#!/bin/sh
mkdir -p /ldio/pipelines
exec java -cp ldio-application.jar -Dloader.path=lib/ org.springframework.boot.loader.launch.PropertiesLauncher