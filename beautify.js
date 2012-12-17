var jsb = require('./node_modules/jsbeautifier/jsb.js'),
	fs = require('fs');
	src = jsb.js_beautify(fs.readFileSync('aztec.preprocessed.js').toString(),{
		preserve_newlines:false,
		preserve_max_newlines: 3
	});
fs.writeFileSync("aztec.release.js",src);