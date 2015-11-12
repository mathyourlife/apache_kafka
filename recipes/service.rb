# encoding: UTF-8
# Cookbook Name:: apache_kafka
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
def create_service(kafka_configuration)
  version_tag = "kafka_#{node['apache_kafka']['scala_version']}-#{node['apache_kafka']['version']}"
  service_name = kafka_configuration['service_name']

  template "/etc/default/#{service_name}" do
    source "kafka_env.erb"
    owner "kafka"
    action :create
    mode "0644"
    variables(
      :kafka_home => ::File.join(node["apache_kafka"]["install_dir"], version_tag),
      :kafka_config => node["apache_kafka"]["config_dir"],
      :kafka_bin => node["apache_kafka"]["bin_dir"],
      :kafka_user => node["apache_kafka"]["user"],
      :scala_version => node["apache_kafka"]["scala_version"],
      :kafka_heap_opts => node["apache_kafka"]["kafka_heap_opts"],
      :jmx_port => kafka_configuration["jmx_port"],
      :jmx_opts => node["apache_kafka"]["jmx"]["opts"],
      :log4j_properties_file_path => kafka_configuration["log4j_properties_file_path"]
    )
    notifies :restart, "service[#{service_name}]", :delayed
  end

  case node["apache_kafka"]["service_style"]
  when "upstart"
    template "/etc/init/#{service_name}.conf" do
      source "kafka.init.erb"
      owner "root"
      group "root"
      action :create
      mode "0644"
      variables(
        :service_name => "#{service_name}",
        :broker_config_file => "#{kafka_configuration['broker_config_file']}"
      )
      notifies :restart, "service[#{service_name}]", :delayed
    end
    service "#{service_name}" do
      provider Chef::Provider::Service::Upstart
      supports :status => true, :restart => true, :reload => true
      action [:start, :enable]
    end
  when "init.d"
    template "/etc/init.d/#{service_name}" do
      source "kafka.initd.erb"
      owner "root"
      group "root"
      action :create
      mode "0744"
      variables(
        :service_name => "#{service_name}",
        :broker_config_file => "#{kafka_configuration['broker_config_file']}"
      )
      notifies :restart, "service[#{service_name}]", :delayed
    end
    service "#{service_name}" do
      provider Chef::Provider::Service::Init
      supports :status => true, :restart => true, :reload => true
      action [:start]
    end
  when "runit"
    include_recipe "runit"

    runit_service "#{service_name}" do
      default_logger true
      action [:enable, :start]
    end
  else
    Chef::Log.error("You specified an invalid service style for Kafka, but I am continuing.")
  end
end

$counter = 0
def set_defaults(broker_config)
  broker_config["service_name"] = broker_config["service_name"] || "kafka-broker-#{$counter}"
  broker_config["broker_config_file"] = broker_config["broker_config_file"] || "#{broker_config["service_name"]}.properties"
  broker_config["log4j_properties"] = broker_config["log4j_properties"] || "#{broker_config["service_name"]}.properties"
  broker_config["log4j_properties_file_path"] = broker_config["log4j_properties_file_path"] || "#{node["apache_kafka"]["config_dir"]}/log4j-#{broker_config["service_name"]}.properties"
  $counter = $counter + 1
end

def run
  broker_configs = Array.new(node["apache_kafka"]["brokers"])
  if broker_configs.nil? || broker_configs.empty?
    broker_id = node["apache_kafka"]["broker.id"]
    broker_id = 0 if broker_id.nil?
    broker_configs << {
        "jmx_port" => node["apache_kafka"]["jmx"]["port"],
        "service_name" => "kafka",
        "broker_config_file" => "server.properties",
        "log4j_properties_file_path" => "#{node["apache_kafka"]["config_dir"]}/log4j.properties"
    }
  end

  broker_configs.each do |broker_config|
    config = Mash.from_hash(broker_config)
    set_defaults(config)
    create_service(config)
  end
end

run
