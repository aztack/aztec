/**
 * description
 */
(function () {
    var event = $AZTEC$.event = {};
    $AZTEC$.config.modules['browser.event'] = event;

    event.addEventListener = function (ele,name,callback) {
        if(!ele) return;
        if(ele.addEventListener) {
            ele.addEventListener(name,callback);
        } else if(ele.attachEvent){
            ele.attachEvent('on' + name,callback);
        } else {
            ele['on' + name] = callback;
        }
    };

    event.removeEventListener = function (ele,name,callback) {
    };

    event.preventDefault = function (e) {
    };

    event.stopPropagation = function(e) {
    };
})();
//# if defined :TEST
//# end
