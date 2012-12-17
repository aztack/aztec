/********************
 * Object
 ********************/
(function () {
    var object = $AZTEC$.object = {};
    $AZTEC$.config.modules['lang.object'] = object;

    object.extend = function (target, source) {
        for (var i in source) {
            if($hasOwnProperty.call(source,i)){
                target[i] = source[i];
            }
        }
        return target;
    };
    
    if (!$IS_FUNCTION$($keys)) {
        object.keys = function (target) {
            var keys = [], key;
            for (key in target) {
                if ($hasOwnProperty.call(target, key)) {
                    keys.push(key);
                }
            }
            return keys;
        };
    }
})();
