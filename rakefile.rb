#encoding:utf-8
require 'erb'
require 'open3'
require 'stringio'
require './bin/java_script_toolkit.rb'


if $0 === __FILE__
    $stdout.puts "Generating aztack.preprocessed.js"
    File.open('release/aztec.preprocessed.js','w').puts JavaScriptToolkit::Preprocessor.parse('./src/aztec.js',{
        :keep_line_number => true,
        :macros => {:NATIVE => true,:TEST => false, :NODEJS => false}
    })
else
    require 'pp'
    namespace :build do
        desc 'build code for browser'
        task :browser do |task, args|
            options = {
                :macros => {
                    :BROWSER => true,
                    :NATIVE => false,
                    :TEST => false
                },
                :keep_line_number => true
            }
            pp options
            JavaScriptToolkit::Preprocessor.write("release/aztec.preprocessed.js",'./src/aztec.js',options)
            system('release.cmd')
        end

        desc 'build code for test'
        task :test do |task,args|
            options = {
                    :macros => {
                            :BROWSER => true,
                            :NATIVE => false,
                            :TEST => true
                    },
                    :keep_line_number => true
            }
            pp options
            JavaScriptToolkit::Preprocessor.write("release/aztec.preprocessed.js",'./src/aztec.js',options)
        end
    end
    
    desc 'check syntax'
    task :lint do |task,args|
        raise NotImplementedError
    end
    
    desc 'create new file'
    task :new, :path do |task,args|
        path = args.path
        if File.exists? path
            raise "#{path} already exists!"
            return
        end
        begin
            path = "src/#{path}"
            
            File.open path,"w" do |file|
                file.puts [
                    '/**',
                    ' * description',
                    ' */',
                    '//# if defined :NATIVE',
                    '//# else',
                    '//# end',
                    '//# if defined :TEST',
                    '//# end'
                ].join "\n"
            end
            $stdout.puts "create #{path} successfully!"
        rescue => e
            $stderr.puts "create #{path} failed!\n#{e}"
        end
    end
    
    desc 'list exits module and functions'
    task :list do |task,args|
        $stdout.puts Dir['src/**/*.js',''].map{|e|e.sub 'src/',''}.sort
    end
end