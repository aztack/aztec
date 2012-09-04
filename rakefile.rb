#encoding:utf-8
require 'erb'

module JavaScript
    class PreprocessorConst;end
    class Preprocessor
        Const = PreprocessorConst;
        Included     = {}
        def initialize(filepath,options = {})
            @options = options
            @path = filepath
            @rawcode = File.open(filepath).read
            @modified = []
            #@macros = {}
            if not options[:macros].nil?
                #@macros.merge! options[:macros]
                options[:macros].each do |k,v|
                    k = k.to_sym
                    if Const.constants.grep k
                        Const.send :remove_const, k rescue nil
                    end
                    Const.send :const_set,k, v
                end
            end
            @result = nil
            @erb = []
            @pass = 0
            @parent = options[:parent]
            @indent = options[:indent] || ''
        end
    
        attr_reader :options,:path,:rawcode,:defines,:indent,:result,:erb
    
        def self.const_missing(name)
            Const.send :const_get, name.to_sym rescue nil
        end
        
        def parse
            # first pass: define constants etc.
            @pass = 1
            @rawcode.split("\n").each do |line|
                line.rstrip!
                if m = line.match(/^(\s*)\/\/\s*#\s*(.*?)$/)
                    m = m.to_a
                    param = nil
                    code,space = m.pop,m.pop
                    if code =~ /[=]\s*include(?:_dir)?/
                        param = ",'#{space}'"
                    end
                    erbcode = "#{space}<%#{code}#{param} %>"
                    if @options[:keep_line_number].nil?
                        if not @modified.size.zero?
                            @modified[-1] << erbcode
                        else
                            @modified << erbcode
                        end
                    else
                        @modified << erbcode
                    end
                else
                    @modified << line
                end
            end
            @erb << @modified.dup
            ERB.new(@modified.join("\n")).result(binding)
            
            # 2nd pass: substitution and code generation
            @pass = 2
            @modified.each_with_index do |line,i|
                next if line.empty?
                @modified[i] = line.gsub /\$(.*?)\$/ do |match|
                    name = match.gsub /^\$|\$$/,''
                    Const.constants.grep(name) ? "<%=#{name}%>" : match
                end
            end
            indent = @options[:indent] || ""
            indent += @parent.indent unless @parent.nil?
            @modified = indent + @modified.join("\n" + indent)
            @result = ERB.new(@modified).result binding
            self
        end
    
        def include(path, indent = "")
            return if @pass === 1
            realpath = File.expand_path(path,File.dirname(@path));
            parser = self.class.new(realpath,{
                :indent => indent,
                :parent => self
                #:macros => @macros
            })
            parser.parse
            #@macros.merge! parser.macros
		    @erb.concat parser.erb
        
            if @options[:output_include_file]
                "\n" + indent + "//#{path}" + parser.result
            else
                "\n" + parser.result.sub(/^\n/,'')
            end
        end
        
        #bug
        def include_once(path,indent = "")
            unless Included[path]
                include path,indent
                Included[path] = true
            end
            ''
        end
    
        def include_dir(dir,indent = "")
            return if @pass === 1
            result = [];
            Dir[File.expand_path(dir,File.dirname(@path))].each do |path|
                result << include(path, indent)
            end
            result.join
        end
    
        def define(*args)
            args.flatten!
            name = args.first.to_sym
        
            if name =~ /^[A-Z0-9_]+$/
                value = block_given? ? yield : args.last
                if Const.constants.grep name
                    Const.send :remove_const, name rescue nil
                end
                Const.send :const_set, name, value
            else
                raise "`#{name}':defined constant must match agaist! /^[A-Z0-9_]+$/"
            end
            #@macros[name] = value.respond_to?(:call) ? value.call : value
            self
        end
    
        def undefine(name)
            Const.send :remove_const, name.to_sym rescue nil
            self
        end
    
        def defined(key,value = nil)
            key = key.to_sym
            v = Const.send(:const_get,key) rescue nil
            value.nil? ? (!!v) : (v == value) 
        end
    end
end

if $0 === __FILE__
    $stdout.puts JavaScript::Preprocessor.new('./src/aztec.js',{
        :keep_line_number => true,
        :macros => {:NATIVE => true,:TEST => false, :NODEJS => false}
    }).parse.result
else
    
    desc 'build release code'
    task :build, :native,:test,:nodejs do |task, args|
        macros = {
            :NATIVE => !!args.native,
            :TEST   => !!args.test,
            :NODEJS => !!args.nodejs
        }
        File.open "aztec.release.js", "w" do |file|
			file.puts JavaScript::Preprocessor.new('./src/aztec.js',{:macros => macros}).parse.result
            puts "build '#{macros.to_s}' OK!"
        end
    end
    
    desc 'check syntax'
    task :lint do |task,args|
        raise NotImplementedError
    end
    
    desc 'test'
    task :test, :native do |task,args|
        Rake::Task[:build].invoke !!args.native, true, true
    end
end