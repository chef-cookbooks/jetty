#
# Cookbook Name:: jetty
# Recipe:: common
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

# Define root owned folders
root_dirs = [
    node["jetty"]["config_dir"],
    node["jetty"]["home"]
]

# Create root folders
root_dirs.each do |dir|
  directory dir do
    owner "root"
    group "root"
    mode "755"
    recursive true
  end
end

# Define jetty owned folders
jetty_dirs = [
    node["jetty"]["webapp_dir"],
    node["jetty"]["log_dir"],
    node["jetty"]["context_dir"],
    node["jetty"]["tmp_dir"]
]

# Create jetty folders
jetty_dirs.each do |dir|
  directory dir do
    owner node['jetty']['user']
    group node['jetty']['group']
    mode "755"
    recursive true
    # Only execute this if jetty can't write to it. This handles cases of
    # dir being world writable (like /tmp)
    # [ File.word_writable? doesn't appear until Ruby 1.9.x ]
    not_if "su #{node['jetty']['user']} -c \"test -d #{dir} && test -w #{dir}\""
  end
end
