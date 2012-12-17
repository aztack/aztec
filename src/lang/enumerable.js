/********************
 * Enumerable
 ********************/
(function () {
    var enumerable = $AZTEC$.enumerable = {};
    $AZTEC$.config.modules['lang.enumerable'] = enumerable;

    var $forEach = enumerable.forEach = function (ary, callback) {
        var i = 0, len = ary.length;
        for (; i < len; ++i) {
            callback(ary[i]);
        }
    };

    enumerable.inject = function(coll, initValue, callback) {
        $forEach(coll,function(item){
            initValue = callback(initValue, item);
        });
        return initValue;
    };
})();
