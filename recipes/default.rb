#
# Cookbook Name:: jetty
# Recipe:: default
#
# Copyright 2010, Opscode, Inc.
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

include_recipe "java"

prefix = "jetty-distribution"
tarball = "#{prefix}-#{node['jetty']['version']}.tar.gz"
url = "http://eclipse.org/downloads/download.php?file=/jetty/#{node['jetty']['version']}/dist/#{tarball}&r=1"
output_dir = File.join(node['jetty']['install_dir'], "#{prefix}-#{node['jetty']['version']}")

file "/tmp/java.info" do
  action :create
  content "#{node[:java]}"
end
group node['jetty']['group'] do
  action :create
end
user node['jetty']['user'] do
  action :create
  home node['jetty']['home']
  gid node['jetty']['group']
end
[node['jetty']['install_dir'], node['jetty']['config_dir'], node['jetty']['log_dir'], node['jetty']['tmp_dir'], node['jetty']['context_dir'], node['jetty']['webapp_dir']].each do |dir|
  directory dir do
    action :create
    owner node['jetty']['user']
    group node['jetty']['group']
    mode "0755"
    recursive true
  end
end

unless File.exists?(output_dir)

  remote_file "#{Chef::Config[:file_cache_path]}/#{tarball}" do
    source url
    mode "0644"
    checksum node["jetty"]["md5"]
  end
  bash "Extract tarball" do
    user node['jetty']['user']
    cwd node['jetty']['install_dir']
    code <<-EOH
      tar -xvzf #{Chef::Config[:file_cache_path]}/#{tarball}
    EOH
  end
  link node['jetty']['home'] do
    to output_dir
  end
end

link "/etc/init.d/jetty" do
  to "#{node['jetty']['home']}/bin/jetty.sh"
end

template "/etc/default/jetty" do
  source "default_jetty.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[jetty]"
end

template "#{node['jetty']['config_dir']}/jetty.xml" do
  source "jetty.xml.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[jetty]"
end

service "jetty" do
  case node["platform"]
  when "centos","redhat","fedora"
    service_name "jetty"
    supports :restart => true
  when "debian","ubuntu"
    service_name "jetty"
    supports :restart => true, :status => true
    action [:enable, :start]
  end
end