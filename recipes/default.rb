# encoding: UTF-8
# Cookbook Name:: kafka_broker
# Recipe:: default
#

include_recipe "kafka_broker::install"
include_recipe "kafka_broker::configure"
include_recipe "kafka_broker::service"
