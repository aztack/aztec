/**
 * convert string into integer
 */
//# if defined :NATIVE
exports.to_i = function(radix) {
    return parseInt(this, radix || 10);
};
//# else
exports.to_i = function(s,radix) {
    return parseInt(s, radix || 10);
};
//# end
//# if defined :TEST

//# end