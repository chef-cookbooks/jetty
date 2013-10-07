#
# Cookbook Name:: jetty
# Recipe::eclipse
#
# Copyright 2012, Opscode, Inc.
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

jetty_tar_gz = File.join(Chef::Config[:file_cache_path], "/", "jetty-distribution-#{node["jetty"]["eclipse"]["version"]}.tar.gz")

eclipse_mirror = node["jetty"]["eclipse"]["mirror"]

remote_file jetty_tar_gz do
  source "#{eclipse_mirror}/jetty/#{node["jetty"]["eclipse"]["version"]}/dist/jetty-distribution-#{node["jetty"]["eclipse"]["version"]}.tar.gz"
  mode "0644"
  action :create_if_missing 
end

execute "untar jetty" do
  command "tar -xzf #{jetty_tar_gz} -C /opt"
  creates "/opt/jetty-distribution-#{node["jetty"]["eclipse"]["version"]}"
  action :run
end

execute "link jetty-distribution-#{node["jetty"]["eclipse"]["version"]} to /opt/jetty" do
  command "ln --force --symbolic --no-target-directory /opt/jetty-distribution-#{node["jetty"]["eclipse"]["version"]} /opt/jetty"
  action :run
end

execute "copy jetty startscript" do
  command "cp /opt/jetty/bin/jetty.sh /etc/init.d/jetty"
  creates "/etc/init.d/jetty"
  action :run
end

user "jetty" do
   comment "jetty user"
   system true
   shell "/bin/false"
end

directory node["jetty"]["log_dir"] do
  owner "jetty"
  group "jetty"
  mode "0755"
  action :create
end

execute "fixup /opt/jetty owner" do
  command "chown -HRf jetty /opt/jetty"
end

service "jetty" do
  case node["platform"]
  when "centos","redhat","fedora"
    service_name "jetty6"
    supports :restart => true
  when "debian","ubuntu"
    service_name "jetty"
    supports :restart => true, :status => true
    action [:enable]
  end
end

template "/etc/default/jetty" do
  source "default_jetty.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[jetty]"
end
