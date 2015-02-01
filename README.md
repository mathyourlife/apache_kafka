# Kafka Broker Cookbook

Install and configure a kafka broker.  Default installation assumes a local
zookeeper instance (see [SimpleFinance/chef-zookeeper](https://github.com/SimpleFinance/chef-zookeeper)).

Based off the work of [Federico Gimenez Nieto](https://github.com/fgimenez/kafka-cookbook)

## Cookbooks

* `kafka_broker::default`
    - Full default install
* `kafka_broker::install`
    - Install the application, but do not start
    - Useful for wrapper cookbooks that want custom configurations before starting
* `kafka_broker::configure`
    - Create the broker configs
* `kafka_broker::service`
    - Create service upstart scripts

## Contributing

* Standard PR model with details on why

## Version Control

Major.Minor.Patch managed via thor

**Sample patch bump to master after PR merge**
```
git checkout master
git pull
bundle exec thor version:bump patch
```

## Test Converge

```bash
bundle install --path vendor/bundle
bundle exec berks install
bundle exec kitchen converge
```