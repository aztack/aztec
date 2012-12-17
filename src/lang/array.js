/// <reference path="../utils.js" />
/********************
 * Array
 ********************/
(function () {
    var array = $ARRAY$;
    array.forEach = $forEach || function (ary, callback) {
        var i = 0, len = ary.length;
        for (; i < len; ++i) {
            callback(ary[i]);
        }
    };
})();
