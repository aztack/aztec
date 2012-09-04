/**
 * Aztec JavaScript Library
 */

var aztec = aztec || { version: $VERSION$, 'native': false };
/**
* String
*/
aztec.string = { };
(function (exports) {    
    /**
     * capitalzie string started with letters
     */
    exports.capitalize = function(s) {
        return s.replace( /^([a-zA-Z])/ , function(a, m, i) {
            return m.toUpperCase();
        });
    };
    
    exports.strip = function(s) {
        return s.replace( /^\s*|\s*$/ , '');
    };
    
    exports.to_i = function(s) {
        return parseInt(s, radix || 10);
    };
})(aztec.string);
/**
 * Array
 */
aztec.array = { };
(function (exports) {    
    /**
     * zip
     */
})(aztec.array);
