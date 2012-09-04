/**
 * Aztec JavaScript Library
 * build flags: native:false,test:false,nodejs:false
 */
(function (exports) {
    exports.version = '0.0.1';
    exports.native = false;
    
    /********************
     * String
     ********************/
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
        /**
         * strip off leading & trailling whitespace
         */
        exports.strip = function(s) {
            return s.replace( /^\s*|\s*$/g , '');
        };
        
        /**
         * convert string into integer
         */
        exports.to_i = function(s,radix) {
            return parseInt(s, radix || 10);
        };
    })(aztec.string);
    
    /********************
     * Array
     ********************/
    aztec.array = { };
    (function (exports) {    
        /**
         * zip
         */
    })(aztec.array);
    
    
    
})(typeof exports === 'undefined' ? (aztec = {}) : exports);
