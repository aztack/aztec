#encoding:utf-8
require 'erb'
require 'open3'
require 'stringio'

#
# JavaScript Tookit
# include a JavaScript Preprocessor,
# a JavaScript Linter, a Minifier
#
module JavaScriptToolkit
    
    #
    # all Preprocessor#define will define constants
    # in PreprocessorConst and share constants with call const_get
    # on PreprocessorConst in Preprocessor.const_missing
    #
    # all Preprocessor#macro will define methods
    # on PreprocessorConst::ConstInstance, the only PreprocessorConst
    # instance. Preprocessor will find methods, with method_missing, in this instance
    # if it can not find a method
    # 
    class PreprocessorConst;end
    
    #
    # JavaScript Preprocessor
    #
    class Preprocessor
        Const = PreprocessorConst;
        ConstInstance = Const.new;
        
        def Preprocessor.parse(*args)
            return Preprocessor.new(*args).parse.result
        end
        
        def Preprocessor.write(path,*args)
            File.open(path,"w") do |file|
                file.puts Preprocessor.parse(*args)
            end
        end
        
        #
        # options = {
        #   :parent => internal use
        #   :indent => internal use
        #   :keep_line_number => preprocess code will replace with empty line
        #   :output_include_file => output included file name
        # }
        #
        def initialize(filepath,options = {})
            @pass     = 0
            @result   = nil    
            @erb      = []
            @modified = []
            @path     = filepath
            @options  = options
            @parent   = options[:parent]
            @indent   = options[:indent] || ''
            @rawcode  = File.open(filepath).read
            
            if not options[:macros].nil?
                options[:macros].each do |k,v|
                    k = k.to_sym
                    if Const.constants.grep k
                        Const.send :remove_const, k rescue nil
                    end
                    Const.send :const_set,k, v
                end
            end
        end
    
        attr_reader :options,:path,:rawcode,:defines,:indent,:result,:erb
    
        def self.const_missing(name)
            Const.send :const_get, name.to_sym rescue "$#{name}$"
        end
        
        def method_missing(name,*args)
            name = name.to_sym
            if ConstInstance.respond_to? name
                ConstInstance.send name, *args
            else
                name.to_s
            end
        end
        
        #
        # parse
        #
        def parse
            # first pass: define constants etc.
            @pass = 1
            @rawcode.split("\n").each do |line|
                line.rstrip!
                if m = line.match(/^(\s*)\/\/\s*#\s*(.*?)$/)
                    m = m.to_a
                    param = nil
                    # deal with include indention
                    code,space = m.pop,m.pop
                    if code =~ /[=]\s*include(?:_dir)?/
                        param = ",'#{space}'"
                        if code.rstrip.end_with? ')'
                            code = code.rstrip.chop
                            param << ")"
                        end
                    end
                    
                    # deal with trailing line feed
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
                @modified[i] = line.gsub /\$(.*?)\$(\(.*?\))*/ do |match|
                    name = match.gsub(/^\$|\$$/,'').gsub('$(','.call("').gsub(',','","').sub(/\)$/,'")')
                    Const.constants.grep(name) ? "<%=#{name}%>" : match
                end
            end
            indent = @options[:indent] || ""
            indent += @parent.indent unless @parent.nil?
            @modified = indent + @modified.join("\n" + indent)
            #@result = ERB.new(@modified).src
            @result = ERB.new(@modified).result binding
            
            
            self
        end
    
        #
        # include another source file into current file
        # //#=include(path) will output included file
        # //# include(path) will only define constants in that file
        #
        def include(path, indent = "")
            return if @pass === 1
            realpath = File.expand_path(path,File.dirname(@path));
            parser = self.class.new(realpath,{
                :indent => indent,
                :parent => self
            })
            parser.parse
		    @erb.concat parser.erb
        
            if @options[:output_include_file]
                "\n" + indent + "//#{path}" + parser.result
            else
                "\n" + parser.result.sub(/^\n/,'')
            end
        end
        
        def include_dir(dir,indent = "")
            return if @pass === 1
            result = [];
            Dir[File.expand_path(dir,File.dirname(@path))].each do |path|
                result << include(path, indent)
            end
            result.join
        end
        
        #
        # define constant
        #
        def define(*args,&block)
            args.flatten!
            name = args.first.to_sym
        
            if name =~ /^[A-Z0-9_]+$/
                value = block.nil? ? args.last : block
                if Const.constants.grep name
                    Const.send :remove_const, name rescue nil
                end
                Const.send :const_set, name, value
            else
                raise "`#{name}':defined constant must match agaist! /^[A-Z0-9_]+$/"
            end
            self
        end
        
        #
        # define macro
        #
        def macro(name,&block)
	        self.class.send :define_method, name.to_sym, block
        end
    
        #
        # undefine constant
        #
        def undefine(name)
            Const.send :remove_const, name.to_sym rescue nil
            self
        end
    
        #
        # return whether a constant
        #
        def defined(key,value = nil)
            key = key.to_sym
            v = Const.send(:const_get,key) rescue nil
            value.nil? ? (!!v) : (v == value) 
        end
    end
    
    class Preprocessor::Shell
    end
    
    module Lint
	    #This file contains methods to lint js file or javascript code

	    # The path to jsl.exe js.conf
	    EXE  = File.expand_path("jsl.exe",File.dirname(__FILE__));
	    CONF = File.expand_path('jsl.conf',File.dirname(__FILE__))
	    CMD_LINE = "#{EXE} -conf #{CONF} "
	    ENDL = "\n".force_encoding("utf-8")
	    SKIP_DESC = 3 # skip jslint description

	    module_function

	    # Make stream from string if neccessary
	    def streamify(stream_or_string) #:nodoc:
		    if IO === stream_or_string || StringIO === stream_or_string
			    stream_or_string
		    elsif String === stream_or_string
			    StringIO.new(stream_or_string.to_s)
		    else
			    raise ArgumentError, 'Stream or string required'
		    end
	    end

	    # Return command acorrding to the type of argument
	    def command(js)
		    CMD_LINE + (File.exists?(js) ? %Q[ -process "#{js}"] : " -stdin")
	    end

	    # Lint given string or js file
	    def lint(js)
		    stream = streamify(js)
		    cmd = command(js)
		    Open3.popen3(cmd) do |input,output,error,thread|
			    #begin
				    while buffer = stream.read(4096)
					    input.write(buffer)
				    end
				    input.close_write
				    result = output.read.force_encoding("utf-8").split(ENDL)[SKIP_DESC..-1].join(ENDL)
				    yield result if block_given?
				    result
			    #rescue Exception => e
			    #	raise 'JSLint failed: %s' % e
			    #end
		    end
	    end
    end
    
    module Minify
      # The path to the YUI Compressor jar file.
      JAR_FILE = File.expand_path('yuic.jar', File.dirname(__FILE__))

      module_function

      # Compress the given CSS +stream_or_string+ using the given +options+.
      # Options should be a Hash with any of the following keys:
      #
      # +:line_break+::   The maximum number of characters that may appear in a
      #                   single line of compressed code. Defaults to no maximum
      #                   length. If set to 0 each line will be the minimum length
      #                   possible.
      def compress_css(stream_or_string, options={}, &block)
        compress(stream_or_string, options.merge(:type => 'css'), &block)
      end

      # Compress the given JavaScript +stream_or_string+ using the given +options+.
      # Options should be a Hash with any of the following keys:
      #
      # +:line_break+::   The maximum number of characters that may appear in a
      #                   single line of compressed code. Defaults to no maximum
      #                   length. If set to 0 each line will be the minimum length
      #                   possible.
      # +:munge+::        Should be +true+ if the compressor should shorten local
      #                   variable names when possible. Defaults to +false+.
      # +:preserve_semicolons+::  Should be +true+ if the compressor should preserve
      #                           all semicolons in the code. Defaults to +false+.
      # +:optimize+::     Should be +true+ if the compressor should enable all
      #                   micro optimizations. Defaults to +true+.
      def compress_js(stream_or_string, options={}, &block)
        compress(stream_or_string, options.merge(:type => 'js'), &block)
      end

      def default_css_options #:nodoc:
        { :line_break => nil }
      end

      def default_js_options #:nodoc:
        default_css_options.merge(
          :munge => false,
          :preserve_semicolons => false,
          :optimize => true
        )
      end

      def streamify(stream_or_string) #:nodoc:
        if IO === stream_or_string || StringIO === stream_or_string
          stream_or_string
        elsif String === stream_or_string
          StringIO.new(stream_or_string.to_s)
        else
          raise ArgumentError, 'Stream or string required'
        end
      end
  
      # Returns an array of flags that should be passed to the jar file on the
      # command line for the given set of +options+.
      def command_arguments(options={})
        args = []
        args.concat(['--type', options[:type].to_s]) if options[:type]
        args.concat(['--line-break', options[:line_break].to_s]) if options[:line_break]

        if options[:type].to_s == 'js'
          #args << '--nomunge' unless options[:munge]
          args << '--preserve-semi' if options[:preserve_semicolons]
          args << '--disable-optimizations' unless options[:optimize]
        end
	
	    output = options[:output].to_s
	    if not File.exists?(output) and not output.size.zero?
		    args << %Q[-o "#{options[:output]}"]
	    end

        args
      end

      # Compresses the given +stream_or_string+ of code using the given +options+.
      # When using this method directly, at least the +:type+ option must be
      # specified, and should be one of <tt>"css"</tt> or <tt>"js"</tt>. See
      # YUICompressor#compress_css and YUICompressor#compress_js for details about
      # which options are acceptable for each type of compressor.
      #
      # In addition to the standard options, this method also accepts a
      # <tt>:java</tt> option that can be used to specify the location of the Java
      # binary. This option will default to using <tt>"java"</tt> unless otherwise
      # specified.
      #
      # If a block is given, it will receive the IO output object. Otherwise the
      # output will be returned as a string.
      def compress(stream_or_string, options={})
        raise ArgumentError, 'Option :type required' unless options.key?(:type)

        stream = streamify(stream_or_string)

        case options[:type].to_s
        when 'js'
          options = default_js_options.merge(options)
        when 'css'
          options = default_css_options.merge(options)
        else
          raise ArgumentError, 'Unknown resource type: %s' % options[:type]
        end

        command = [ options.delete(:java) || 'java', '-jar', JAR_FILE ]
        command.concat(command_arguments(options))
	    command << '--charset utf8'
        Open3.popen3(command.join(' ')) do |input, output, stderr|
          begin
            while buffer = stream.read(4096)
              input.write(buffer)
            end
            input.close_write
            output.read.force_encoding("utf-8")
          rescue Exception => e
            raise 'Compression failed: %s' % e
          end
        end
      end
    end
end

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