/**
 * capitalzie string started with letters
 */
//# if defined(:Native)
exports.capitalize = function() {
    return this.replace( /^([a-zA-Z])/ , function(a, m, i) {
        return m.toUpperCase();
    });
};
//# else
exports.capitalize = function(s) {
    return s.replace( /^([a-zA-Z])/ , function(a, m, i) {
        return m.toUpperCase();
    });
};
//# end
