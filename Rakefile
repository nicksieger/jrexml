gem 'rspec'
require 'spec/rake/spectask'

task :default => :spec

Spec::Rake::SpecTask.new do |t|
  t.libs << "lib"
  t.spec_files = FileList['spec/**/*_spec.rb']
end

task :benchmark do
  $LOAD_PATH.unshift "lib"
  require 'benchmark'
  require 'rexml/document'

  xml = File.open(File.dirname(__FILE__) + "/spec/atom_feed.xml") {|f| f.read }

  Benchmark.bm(7) do |x|
    x.report("REXML") do
      10.times do
        REXML::Document.new xml
      end
    end
    if RUBY_PLATFORM =~ /java/
      x.report("JREXML") do
        require 'jrexml'
        10.times do
          REXML::Document.new xml
        end
      end
    end
  end
end