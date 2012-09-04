/********************
* unit test
********************/
function test(fn) {
    test._tests = test._tests || []
    test._tests.push(fn);
}
function log(){
    var g = (function(){return this;}).call(null);
    if (g.console && console.log) {
        if (g.navigator && navigator.userAgent.indexOf('MSIE') >= 0) {
            g.console.log(arguments);
        } else {
            g.console.log.apply(console, arguments);
        }
    } else if(typeof g.print !== 'undefined') {
        g.print.apply(g,arguments);
    }
}
function equal(a, b) {return a === b;}
function expect(name, a, b, f) {
    var result = f(a, b);
    log(name, result);
    if (!result) {
        log("a=[" + a + "]");
        log("b=[" + b + "]");
    }
}
(function () {
    for (var i = 0, len = test._tests.length; i < len; ++i) {
        test._tests[i]();
    }
})();
