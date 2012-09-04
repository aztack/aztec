#encoding:utf-8
require 'erb'

class JavaScriptPreprocessor2
    def initialize(filepath,options = {})
        @options = options
        @path = filepath
        @rawcode = File.open(filepath).read
        @modified = []
        @macros = {}
        @macros.merge! options[:macros] || {}
        @parent = options[:parent]
        @result = nil
        @erb = []
    end
    
    attr_reader :options,:path,:rawcode,:defines,:macros,:result,:erb
    
    def const_missing(name)
        unless @parent.nil?
            @parent.send :const_get, name.to_sym
        end
    end
    
    def parse
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
                if not @options[:keep_line_number].nil?
                    @modified << erbcode
                else
                    if not @modified.size.zero?
                        @modified[-1] << erbcode
                    else
                        @modified << erbcode
                    end
                end
            else
                @modified << line
            end
        end
        @erb << @modified.dup
        ERB.new(@modified.join("\n")).result(binding)
        @modified.each_with_index do |line,i|
            if line !~ /^\s*<%.*?%>\s*$/ and line.match /\S/
                @macros.each do |name,_|
                    if name =~ /^[A-Z]/
                        pattern = "$#{name}$"
                        if line[pattern]
                            @modified[i] = line.gsub(pattern,"<%= #{name}%>")
                        end
                    end
                end
            end
        end
        indent = @options[:indent] || ""
        @modified = indent + @modified.join("\n" + indent)
        @result = ERB.new(@modified).result binding
        self
    end
    
    def include(path, indent = "")
        realpath = File.expand_path(path,File.dirname(@path));
        parser = self.class.new(realpath,{
            :parent => self,
            :indent => indent,
            :macros => @macros
        })
        parser.parse
        @macros.merge! parser.macros
		@erb.concat parser.erb
        if @options[:output_include_file]
            "\n" + indent + "//#{path}" + parser.result
        else
            "\n" + parser.result.sub(/^\n/,'')
        end
    end
    
    def include_dir(dir,indent = "")
        result = [];
        Dir[File.expand_path(dir,File.dirname(@path))].each do |path|
            result << include(path, indent)
        end
        result.join
    end
    
    def define(*args)
        args.flatten!
        name = args.first.to_sym
        
        if name =~ /^[A-Z]/
            value = block_given? ? yield : args.last
            if self.class.constants.grep name
                self.class.send :remove_const, name rescue nil
            end
            self.class.send :const_set, name, value
        else
            if block_given?
                self.class.send :define_method, name, yield
            else
                value = Proc.new{ return args.last}
                self.class.send :define_method, name do
                    return args.last
                end
            end
        end
        @macros[name] = value.respond_to?(:call) ? value.call : value
        self
    end
    
    def undefine(name)
        if name.to_s =~ /^[A-Z]/
            self.class.send :remove_const, name
        else
            self.class.send :remove_method, name
        end
        @macros.delete name
        self
    end
    
    def defined(key,value = nil)
        value.nil? ? (!!@macros[key]) : (@macros[key] == value) 
    end
end

if $0 === __FILE__
    #JavaScriptCodeBuilderLanguageParser.new(File.read('./src/lang/string.js'))
    puts JavaScriptPreprocessor2.new('./src/aztec.js').parse.result
else
	BuildOptions = {
		:native => {:macros=>{:Version=>:native}},
		:module => {:macros=>{:Version=>:module}}
	}
    namespace :build do
        desc 'generate release code'
        task :generate, :version do |task, args|
            which = args.version.nil? ? :module : :native
			opt = BuildOptions[which]
            File.open "aztec.release.js", "w" do |file|
				file.puts JavaScriptPreprocessor2.new('./src/aztec.js',opt).parse.result
                puts "build #{which} version OK!"
            end
        end
    end
end