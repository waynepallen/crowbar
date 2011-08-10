# Copyright 2011, Dell 
# 
# Licensed under the Apache License, Version 2.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at 
# 
#  http://www.apache.org/licenses/LICENSE-2.0 
# 
# Unless required by applicable law or agreed to in writing, software 
# distributed under the License is distributed on an "AS IS" BASIS, 
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and 
# limitations under the License. 
# 
# Author: RobHirschfeld 
# 

namespace :crowbar do

  desc "Setup Crowbar on Dev Box"
  task :default do
    puts "nothing yet"
  end

  desc "Copy over Crowbar components to RAILS app"
  task :copy do
    barclamp_into_app(true)
  end

  desc "Copy over Crowbar components to RAILS app"
  task :delete do
    barclamp_into_app(false)
  end
  
  def barclamp_into_app(copy)
    components = ['controllers', 'models', 'views']
    bc_dir = File.join('..', 'barclamps')
    barclamps = Dir.entries(bc_dir).find_all { |d| !d.include?(".") }
    barclamps.each do |bc|
      puts "barclamp #{bc}"
      subdir = Dir.entries(File.join(bc_dir, bc, 'app')).find_all { |rails| components.include? rails  }
      subdir.each do |dir|
        path = File.join('..', 'barclamps', bc, 'app', dir)
        files = Dir.entries(path).find_all { |d| d.end_with?(".rb") }
        files.each do |f|
          if copy 
            puts  "  Copy from #{File.join(path, f)} to #{File.join('app', dir, f)}"
            FileUtils.cp File.join(path, f), File.join('app', dir, f)
          else
            puts  "  Delete from #{File.join(path, f)} to #{File.join('app', dir, f)}"
            FileUtils.rm File.join('app', dir, f)
          end
        end
      end
    end
  end
end