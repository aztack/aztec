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

end