# encoding: UTF-8
# Cookbook Name:: kafka_broker
# Recipe:: service
#
# based on the work by Simple Finance Technology Corp.
# https://github.com/SimpleFinance/chef-zookeeper/blob/master/recipes/service.rb
#
# Copyright 2013, Simple Finance Technology Corp.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

version_tag = "kafka_#{node["kafka_broker"]["scala_version"]}-#{node["kafka_broker"]["version"]}"

case node["kafka_broker"]["service_style"]
when "upstart"
  template "/etc/default/kafka" do
    source "kafka_env.erb"
    owner "kafka"
    action :create
    mode "0644"
    variables(
      :kafka_home => ::File.join(node["kafka_broker"]["install_dir"], version_tag),
      :kafka_config => node["kafka_broker"]["config_dir"],
      :kafka_bin => node["kafka_broker"]["bin_dir"],
      :kafka_log => node["kafka_broker"]["log_dir"],
      :kafka_user => node["kafka_broker"]["user"],
      :scala_version => node["kafka_broker"]["scala_version"],
      :kafka_heap_opts => node["kafka_broker"]["kafka_heap_opts"]
    )
    notifies :restart, "service[kafka]", :delayed
  end
  template "/etc/init/kafka.conf" do
    source "kafka.init.erb"
    owner "root"
    group "root"
    action :create
    mode "0644"
    notifies :restart, "service[kafka]", :delayed
  end
  service "kafka" do
    provider Chef::Provider::Service::Upstart
    supports :status => true, :restart => true, :reload => true
    action [:start, :enable]
  end
else
  Chef::Log.error("You specified an invalid service style for Kafka, but I am continuing.")
end
