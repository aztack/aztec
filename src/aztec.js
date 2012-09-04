/**
 * Aztec JavaScript Library
 * build flags: native:$NATIVE$,test:$TEST$,nodejs:$NODEJS$
 */
//# include 'version.js'
(function (exports) {
    exports.version = '$VER$';
    exports.native = $NATIVE$;
    
    //#=include 'lang/string.js'

    //#=include 'lang/array.js'
    
    //#=include 'lang/hash.js'

    //# if defined :TEST
    //#=    include 'unittest.js'
    //# end
})(typeof exports === 'undefined' ? (aztec = {}) : exports);