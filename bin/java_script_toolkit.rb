#
# JavaScript Tookit
# include a JavaScript Preprocessor,
# a JavaScript Linter, a Minifier
#
module JavaScriptToolkit
    dir = File.join(File.dirname(__FILE__),'JavaScriptToolkit')
    %w(preprocessor lint compressor).each do |m|
        require File.join(dir,"#{m}.rb")
    end
end