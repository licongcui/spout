require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/**/*_test.rb']
  t.warning = true
  t.verbose = true
end

task :default => :test

namespace :dd do
  require 'csv'
  require 'fileutils'
  require 'rubygems'
  require 'json'

  desc 'Create Data Dictionary from repository'
  task :create do

    folder = "dd/#{ENV['VERSION'] || Spout::Application.new.version}"
    FileUtils.mkpath folder

    CSV.open("#{folder}/variables.csv", "wb") do |csv|
      keys = %w(id display_name description type units domain labels calculation)
      csv << ['folder'] + keys
      Dir.glob("variables/**/*.json").each do |file|
        if json = JSON.parse(File.read(file)) rescue false
          variable_folder = file.gsub(/variables\//, '').split('/')[0..-2].join('/')
          csv << [variable_folder] + keys.collect{|key| json[key].kind_of?(Array) ? json[key].join(';') : json[key].to_s}
        end
      end
    end
    CSV.open("#{folder}/domains.csv", "wb") do |csv|
      keys = %w(value display_name description)
      csv << ['id'] + keys
      Dir.glob("domains/**/*.json").each do |file|
        if json = JSON.parse(File.read(file)) rescue false
          domain_name = file.gsub(/domains\//, '')
          json.each do |hash|
            csv << [domain_name] + keys.collect{|key| hash[key]}
          end
        end
      end
    end

    puts "Data Dictionary Created in #{folder}"
  end

  desc 'Initialize JSON repository from a CSV file: CSV=datadictionary.csv'
  task :import do
    puts ENV['CSV'].inspect
    if File.exists?(ENV['CSV'].to_s)
      CSV.parse( File.open(ENV['CSV'].to_s, 'r:iso-8859-1:utf-8'){|f| f.read}, headers: true ) do |line|
        row = line.to_hash
        next if row['id'] == ''
        folder = File.join('variables', row['folder'])
        FileUtils.mkpath folder
        hash = {}
        id = row.delete('id')
        hash['id'] = id
        hash['display_name'] = row.delete('display_name')
        hash['description'] = row.delete('description').to_s
        hash['type'] = row.delete('type')
        domain = row.delete('domain').to_s
        hash['domain'] = domain if domain != ''
        units = row.delete('units').to_s
        hash['units'] = units if units != ''
        calculation = row.delete('calculation').to_s
        hash['calculation'] = calculation if calculation != ''
        labels = row.delete('labels').to_s.split(';')
        hash['labels'] = labels if labels.size > 0
        hash['other'] = row

        file_name = File.join(folder, id.downcase + '.json')
        File.open(file_name, 'w') do |file|
          file.write(JSON.pretty_generate(hash))
        end
        puts "      create  #{file_name}"
      end
    else
      puts "Please specify a valid CSV file."
    end
  end
end
