
type.Class = function(ctor,base,opts) {
};

type.root = [{name:'Class', constructor: type.Class, base: null}];
type.find = function(name) {
    var root = type.root, i = 1, len = root.length, klass;
    for(; i < len; ++i) {
        klass = root[i];
        if(klass.name === name) return klass;
    }
    return null;
};

type.create = function (name, superclass, ctor, opts) {
    var argLen = arguments.length;
    var root = type.root,
        klass = function () {
            ctor.apply(this, arguments);
        };
    klass.prototype = new superclass();
    klass.def = function (name, value) {
        var len = arguments.length, name, value;
        if (len === 1) {
            _mix(klass.prototype, obj);
        } else if (len === 2) {
            name = name.toString();
            if (!/\[object .*?\]/.test(name)) {
                klass.prototype[name.toString()] = value
            }
        }
        return this;
    };

    root[root.length] = {
        name: name,
        constructor: klass,
        superclass: type.find(superclass) || root[0]
    };
    return klass;
};

