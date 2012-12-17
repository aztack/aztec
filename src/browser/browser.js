/**
* browser
* http://www.useragentstring.com/pages/useragentstring.php
*/

!$IS_UNDEFINED$(window) && (function () {

    var browser = $AZTEC$.browser = {},
        ua = navigator.userAgent,
        rChrome = /(Chrome).*?(\d+\.\d+)/i,
        rOpera = /Opera(\/| )(\d+(\.\d+)?)(.+?(version\/(\d+(\.\d+)?)))?/i ,
        rMsie = /MSIE (\d+)/i,
        rFirefox = /Firefox\/(\d+\.\d+)/i,
        m;

    $AZTEC$.config.modules['browser'] = browser;

    if(m = ua.match(rChrome)) {
        browser.chrome = {
            value: m[2],
            valueOf: _valueOf
        };
    }
    
    if(m = ua.match(rOpera)) {
        browser.opera = {
            value: m[2] || m[6],
            valueOf: _valueOf
        };
    }
    
    if(m = ua.match(rMsie)) {
        browser.msie = {
            value: m[1],
            valueOf: _valueOf
        };
    }
    
    if(m = ua.match(rFirefox)) {
        browser.firefox = {
            value: m[1],
            valueOf: _valueOf
        };
    }
})();