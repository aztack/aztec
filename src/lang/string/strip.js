/**
 * strip off leading & trailling whitespace
 */
//# if defined :NATIVE
exports.strip = function() {
    return this.replace( /^\s*|\s*$/g , '');
};
//# else
exports.strip = function(s) {
    return s.replace( /^\s*|\s*$/g , '');
};
//# end

//# if defined(:TEST) and defined(:NATIVE)
test(function () {
    expect(
        'String#strip case1',
        "  \thello world\t  \t".strip(), 
        "hello world",
        equal
    );

    expect(
        'String#strip case2',
        "  \thello world".strip(),
        "hello world",
        equal
    );

    expect(
        'String#strip case3',
        "hello world\t  \t".strip(),
        "hello world",
        equal
    );
});
//# end



