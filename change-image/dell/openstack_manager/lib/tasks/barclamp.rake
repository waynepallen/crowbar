# Copyright 2011, Dell
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Author: RobHirschfeld
#

namespace :barclamp do

  require File.join '..', 'barclamp_install'
  
  desc "Create a new barclamp"
  task :create, :name, :entity, :target, :needs=>[] do |t, args|
    files = []
    puts args.inspect
    args.with_defaults(:entity => 'Dell', :target => MODEL_TARGET)
    bc = args.name
    target = File.join args.target, bc
    if bc.nil?
      puts "You must supply a name to create a barclamp"
    elsif File.exist? File.join target, "crowbar.yml"
      puts "Aborting! A barclamp already exists in '#{target}'."
    else
      puts "Creating barclamp '#{bc}' into '#{target}' as entity '#{args.entity}'."
      FileUtils.mkdir target
      clone = Dir.entries(MODEL_SOURCE).find_all { |e| !e.start_with? '.'}
      clone.each do |item|
        files += bc_cloner(item, bc, args.entity, MODEL_SOURCE, target, true)
      end
    end
    filelist = File.join target, 'filelist.yml'
    File.open( filelist, 'w' ) do |out|
      YAML.dump( {"files" => files }, out )
    end
    puts "Barclamp #{bc} created in #{target}.  Review #{filelist} for files created."
  end
  
  desc "Install a barclamp into an active system"
  task :install, [:bc, :path] do |t, args|
    args.with_defaults(:path => '/opt/dell/barclamps') 
    path = File.join args.path, args.bc
    version = File.join path, 'crowbar.yml'
    unless File.exist? version
      puts "ERROR: could not install barclamp - failed to find required #{version} file"
    else
      barclamp = YAML.load_file(version)
      bc = barclamp["barclamp"]["name"].chomp.strip
      
      case barclamp["crowbar"]["layout"].to_i
      when 0
        bc_install_layout_0 bc, path, barclamp
      else
        puts "ERROR: could not install barclamp #{bc} because #{barclamp["barclamp"]["crowbar_layout"]} is unknown layout."
      end

      puts "done."

    end
  end

  desc "Install a barclamp into an active system"
  task :bootstrap, [:path] do |t, args|
    args.with_defaults(:path => '/opt/dell/barclamps') 
    path = args.path
    puts "Boostrapping starting in #{path}."
    clone = Dir.entries(path).find_all { |e| !e.start_with? '.'}
    clone.each do |bc|
      bc_path = File.join path, bc
      if File.exist? File.join bc_path, "crowbar.yml"
        puts "Boostrapping from #{bc_path}"
        Rake::Task['barclamp:install'].invoke(bc_path)
      else
        puts "Skipping #{bc_path} because no crowbar.yml file was found"
      end
    end
    puts "Boostrapping done."
  end

  desc "Install a barclamp into an active system"
  task :install, [:path] do |t, args|
    path = args.path || "/opt."
    version = File.join path, 'crowbar.yml'
    unless File.exist? version
      puts "ERROR: could not install barclamp - failed to find required #{version} file"
    else
      barclamp = YAML.load_file(version)
      bc = barclamp["barclamp"]["name"].chomp.strip
      
      case barclamp["crowbar"]["layout"].to_i
      when 1
        bc_install_layout_1_app bc, path, barclamp
        bc_install_layout_1_chef bc, path, barclamp
      else
        puts "ERROR: could not install barclamp #{bc} because #{barclamp["barclamp"]["crowbar_layout"]} is unknown layout."
      end

      puts "done."

    end
  end

end
