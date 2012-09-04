//# if defined(:Native)
exports.strip = function() {
    return this.replace( /^\s*|\s*$/ , '');
};
//# else
exports.strip = function(s) {
    return s.replace( /^\s*|\s*$/ , '');
};
//# end

