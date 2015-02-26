# encoding: UTF-8
# Cookbook Name:: kafka_broker
# Attribute:: default
#

default["kafka_broker"]["version"] = "0.8.1.1"
default["kafka_broker"]["scala_version"] = "2.10"
default["kafka_broker"]["mirror"] = "http://apache.mirrors.tds.net/kafka"
# shasum -a 256 /tmp/kitchen/cache/kafka_2.10-0.8.1.1.tgz
default["kafka_broker"]["checksum"] = "2532af3dbd71d2f2f95f71abff5b7505690bd1f15c7063f8cbaa603b45ee4e86"

default["kafka_broker"]["user"] = "kafka"

# heap options are set low to allow for local development
default["kafka_broker"]["kafka_heap_opts"] = "-Xmx512M -Xms256M"

default["kafka_broker"]["install_java"] = true

default["kafka_broker"]["install_dir"] = "/usr/local/kafka"
default["kafka_broker"]["log_dir"] = "/var/log/kafka"
default["kafka_broker"]["bin_dir"] = "/usr/local/kafka/bin"
default["kafka_broker"]["config_dir"] = "/usr/local/kafka/config"

default["kafka_broker"]["service_style"] = "upstart"

# Kafka configuration settings are detailed here.
# https://kafka.apache.org/08/configuration.html
# Required settings are specified below as they may need special handling
# by wrapper cookbooks.  All others are fixed at default levels.  This
# allows wrapper cookbooks to override a value then subsequently remove
# the override and allow the host to fall back to the default value.
default["kafka_broker"]["broker.id"] = nil
default["kafka_broker"]["port"] = 9092
default["kafka_broker"]["zookeeper.connect"] = nil

# Check in /var/log/kafka/server.log for invalid entries
#
default["kafka_broker"]["conf"]["server"] = {
  "file" => "server.properties",
  "entries" => {
    ## Settings are set to defaults by kafka but can be optionally
    ## overridden in the server.properties file such as bumping the default
    ## replication factor from 1 to 2 with:
    # "default.replication.factor" => 2,
    #
    # For a full list reference kafka's config documentation
    "log.dirs" => node["kafka_broker"]["log_dir"]
  }
}

default["kafka_broker"]["conf"]["log4j"] = {
  "file" => "log4j.properties",
  "entries" => {
    "log4j.additivity.kafka.controller" => "false",
    "log4j.additivity.kafka.log.LogCleaner" => "false",
    "log4j.additivity.kafka.network.RequestChannel$" => "false",
    "log4j.additivity.kafka.request.logger" => "false",
    "log4j.additivity.state.change.logger" => "false",
    "log4j.appender.cleanerAppender.DatePattern" => "'.'yyyy-MM-dd-HH",
    "log4j.appender.cleanerAppender.File" => "log-cleaner.log",
    "log4j.appender.cleanerAppender.layout.ConversionPattern" => "[%d] %p %m (%c)%n",
    "log4j.appender.cleanerAppender.layout" => "org.apache.log4j.PatternLayout",
    "log4j.appender.cleanerAppender" => "org.apache.log4j.DailyRollingFileAppender",
    "log4j.appender.controllerAppender.DatePattern" => "'.'yyyy-MM-dd-HH",
    "log4j.appender.controllerAppender.File" => "${kafka.logs.dir}/controller.log",
    "log4j.appender.controllerAppender.layout.ConversionPattern" => "[%d] %p %m (%c)%n",
    "log4j.appender.controllerAppender.layout" => "org.apache.log4j.PatternLayout",
    "log4j.appender.controllerAppender" => "org.apache.log4j.DailyRollingFileAppender",
    "log4j.appender.kafkaAppender.DatePattern" => "'.'yyyy-MM-dd-HH",
    "log4j.appender.kafkaAppender.File" => "${kafka.logs.dir}/server.log",
    "log4j.appender.kafkaAppender.layout.ConversionPattern" => "[%d] %p %m (%c)%n",
    "log4j.appender.kafkaAppender.layout" => "org.apache.log4j.PatternLayout",
    "log4j.appender.kafkaAppender" => "org.apache.log4j.DailyRollingFileAppender",
    "log4j.appender.requestAppender.DatePattern" => "'.'yyyy-MM-dd-HH",
    "log4j.appender.requestAppender.File" => "${kafka.logs.dir}/kafka-request.log",
    "log4j.appender.requestAppender.layout.ConversionPattern" => "[%d] %p %m (%c)%n",
    "log4j.appender.requestAppender.layout" => "org.apache.log4j.PatternLayout",
    "log4j.appender.requestAppender" => "org.apache.log4j.DailyRollingFileAppender",
    "log4j.appender.stateChangeAppender.DatePattern" => "'.'yyyy-MM-dd-HH",
    "log4j.appender.stateChangeAppender.File" => "${kafka.logs.dir}/state-change.log",
    "log4j.appender.stateChangeAppender.layout.ConversionPattern" => "[%d] %p %m (%c)%n",
    "log4j.appender.stateChangeAppender.layout" => "org.apache.log4j.PatternLayout",
    "log4j.appender.stateChangeAppender" => "org.apache.log4j.DailyRollingFileAppender",
    "log4j.appender.stdout.layout.ConversionPattern" => "[%d] %p %m (%c)%n",
    "log4j.appender.stdout.layout" => "org.apache.log4j.PatternLayout",
    "log4j.appender.stdout" => "org.apache.log4j.ConsoleAppender",
    "log4j.logger.kafka.controller" => "TRACE, controllerAppender",
    "log4j.logger.kafka" => "INFO, kafkaAppender",
    "log4j.logger.kafka.log.LogCleaner" => "INFO, cleanerAppender",
    "log4j.logger.kafka.network.RequestChannel$" => "WARN, requestAppender",
    "log4j.logger.kafka.request.logger" => "WARN, requestAppender",
    "log4j.logger.state.change.logger" => "TRACE, stateChangeAppender",
    "log4j.rootLogger" => "WARN, stdout "
  }
}
