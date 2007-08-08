require 'spec/rake/spectask'

MANIFEST = FileList["History.txt", "Manifest.txt", "README.txt", "LICENSE.txt", "Rakefile",
  "lib/**/*.rb", "lib/xpp*", "spec/**/*.rb", "spec/*.xml"]

begin
  require 'hoe'
  hoe = Hoe.new("jrexml", "0.5.2") do |p|
    p.rubyforge_name = "caldersphere"
    p.url = "http://caldersphere.rubyforge.org/jrexml"
    p.author = "Nick Sieger"
    p.email = "nick@nicksieger.com"
    p.summary = "JREXML speeds up REXML under JRuby by using a Java pull parser."
    p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
    p.description = p.paragraphs_of('README.txt', 0...1).join("\n\n")
    p.extra_deps.reject!{|d| d.first == "hoe"}
    p.test_globs = ["spec/**/*_spec.rb"]
  end
  hoe.spec.files = MANIFEST
  hoe.spec.dependencies.delete_if { |dep| dep.name == "hoe" }
rescue LoadError
  puts "You really need Hoe installed to be able to package this gem"
end

# Hoe insists on setting task :default => :test
# !@#$ no easy way to empty the default list of prerequisites
Rake::Task['default'].send :instance_variable_set, "@prerequisites", FileList[]

file "Manifest.txt" => :manifest
task :manifest do
  File.open("Manifest.txt", "w") {|f| MANIFEST.each {|n| f << "#{n}\n"} }
end
Rake::Task['manifest'].invoke # Always regen manifest, so Hoe has up-to-date list of files

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