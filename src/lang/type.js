/**
 * type
 */
(function () {
    var type = $AZTEC$.type = {},
        sObject = '[object Object]',
        sNumber = '[object Number]',
        sString = '[object String',
        sArray = '[object String]',
        sFunction = '[object Function]',
        sDate = '[object Date]',
        sRegExp = '[object RegExp]',
        sUndefined = 'undefined';
    $AZTEC$.config.modules['lang.type'] = type;

    type.isNumber = function(n) {
        return isFinite(n) && $toString.call(n) === sNumber;
    };

    type.isString = function(s) {
        return $toString.call(s) === sString;
    };

    type.isArray = Array.isArray || function(a) {
        return $toString.call(a) === sArray;
    };

    type.isFunction = function(f) {
        return $toString.call(f) === sFunction;
    };

    type.isUndefined = function(o) {
        return typeof o === sUndefined;
    };

    type.isNull = function(o) {
        return o === null;
    };

    type.isPlain = function() {
    };
    
    //# if defined(:BROWSER)
    type.isWindow = function(w) {
        return $IS_OBJECT$(w) && $IS_OBJECT$(w.document) && $IS_OBJECT$(w.navigator)
    };
    //# end

    //#=include 'oo.js'
})();
