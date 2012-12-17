module JavaScriptToolkit
    module Compressor
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