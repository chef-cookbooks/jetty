#
# Cookbook Name:: jetty
# Recipe:: default
#
# Copyright 2010-2015, Chef Software, Inc.
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

include_recipe 'java' if node['jetty']['install_java']

case node['platform_family']
when 'rhel', 'fedora'
  include_recipe 'jpackage'

  execute 'install jpackage repo' do
    command 'cd /etc/yum.repos.d/ && wget http://jpackage.org/jpackage50.repo'
    user 'root'
    not_if { File.exists?('/etc/yum.repos.d/jpackage50.repo') }
  end

end

jetty_pkgs = value_for_platform_family(
  'debian' => ['jetty', 'libjetty-extra'],
  %w(rhel fedora) => ['jetty6', 'jetty6-jsp-2.1', 'jetty6-management'],
  'default' => ['jetty']
)

package jetty_pkgs do
  action :install
  options '--nogpgcheck' if ['rhel', 'fedora'].include?(node['platform_family'])
end

template '/etc/default/jetty' do
  source 'default_jetty.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, 'service[jetty]'
end

template "#{node['jetty']['config_dir']}/jetty.xml" do
  source 'jetty.xml.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, 'service[jetty]'
end

service 'jetty' do
  case node['platform_family']
  when 'rhel', 'fedora'
    service_name 'jetty6'
    supports restart: true
  when 'debian'
    service_name 'jetty'
    supports restart: true, status: true
    action [:enable, :start]
  end
end
