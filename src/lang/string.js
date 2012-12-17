/********************
 * String
 ********************/
(function () {
    var string = $STRING$,
    //# if defined(:NATIVE)
        cString = String;
    //# elsif defined(:BROWSER)
        cString = string;
    //# end

    cString.empty = '';

    string.toInt = function (s, radix) {
        return parseInt(s, radix || 10);
    };

    string.toArray = function (s) {
        return $slice(s);
    };

    string.toFloat = function (radix) {
        return parseFloat(this, radix || 10);
    };

    string.capitalize = function (s) {
        return s.replace(/^([a-zA-Z])/, function (a, m, i) {
            return m.toUpperCase();
        });
    };

    string.blank = function (s) {
        return !Boolean(s.match(/\S/));
    };

    string.isEmpty = function (s) {
        return s === string.empty || s.length === 0;
    };

    string.strip = $trim ? function (s) {
        return $.trim.call(s);
    } : function (s) {
        return s.replace(/^\s+|\s+$/g, '');
    };

    string.lstrip = function (s) {
        return s.replace(/^\s+/, '');
    };

    string.rstrip = function (s) {
        return s.replace(/\s+$/, '');
    };

    string.chomp = function (s, sep) {
        if (typeof sep !== 'undefined') {
            return s.replace((new RegExp(sep + '$')), '');
        }

        return s.replace(/[\r\n]$/, '');
    };

    string.chop = function (s) {
        if ($IS_UNDEFINED$(s) || $IS_EMPTY$(s)) {
            return string.empty;
        }
        var a = s.substr(s.length - 1),
            b = s.substr(s.length - 2);
        if (a === '\n' && b === '\r') {
            return a.substring(0, a.length - 2);
        }
        return a.substring(0, a.length - 1);
    };

    string.reverse = function (s) {
        return s.split('').reverse().join('');
    };

    string.eachLine = function (s, block) {
        if ($IS_UNDEFINED$(s)) {
            return;
        }
        var ary = s.split("\n"), i = 0, len = ary.length;
        for (; i < len; ++i) {
            block(ary[i], i, s);
        }
    };

    string.repeat = function (s, n) {
        if (n <= 0) return string.empty;
        if (n === 1) return s;
        if (n === 2) return s + s;
        if (n > 2) return Array(n + 1).join(s);
    };
})();
