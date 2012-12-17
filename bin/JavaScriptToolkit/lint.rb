module JavaScriptToolkit
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
end