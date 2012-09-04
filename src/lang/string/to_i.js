//# if defined(:Native)
exports.to_i = function() {
    return parseInt(this, radix || 10);
};
//# else
exports.to_i = function(s) {
    return parseInt(s, radix || 10);
};
//# end
