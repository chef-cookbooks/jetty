#
# Cookbook Name:: jetty
# Recipe:: cargo
#
# Copyright 2012-2015, Chef Software, Inc.
#
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

include_recipe 'jetty::default'

# The cookbook wont work without a password set so fail if it's not set
unless node['jetty']['cargo']['password']
  Chef::Application.fatal!("Cannot continue unless node['jetty']['cargo']['password'] is set")
end

#template '/etc/jetty/realm.properties' do
template "#{node['jetty']['config_dir']}/realm.properties" do
  source 'realm.properties.erb'
  variables(
    username: node['jetty']['cargo']['username'],
    password: node['jetty']['cargo']['password']
  )
  mode '0644'
  owner 'root'
  group 'root'
  notifies :restart, 'service[jetty]'
end

cookbook_file 'web_xml' do
  source 'web.xml'
  path node['jetty']['webapp_dir'] + '/cargo-jetty-6/WEB-INF/web.xml'
  mode '0644'
  owner 'jetty'
  group 'jetty'
  action :nothing
  notifies :restart, 'service[jetty]'
end

script 'extract war' do
  interpreter 'bash'
  user 'jetty'
  cwd node['jetty']['webapp_dir']
  code <<-EOH
      mkdir cargo-jetty-6
      cd cargo-jetty-6
      jar xf ../cargo-jetty-6-and-earlier-deployer-1.2.2.war
    EOH
  notifies :restart, 'service[jetty]'
  action :nothing
end

remote_file '/usr/share/jetty/webapps/cargo-jetty-6-and-earlier-deployer-1.2.2.war' do
  source node['jetty']['cargo']['jetty6']['source']['url']
  checksum node['jetty']['cargo']['jetty6']['source']['checksum']
  mode '0644'
  owner 'jetty'
  group 'jetty'
  notifies :run, 'script[extract war]', :immediately
  notifies :create, 'cookbook_file[web_xml]', :immediately
  notifies :restart, 'service[jetty]'
end
