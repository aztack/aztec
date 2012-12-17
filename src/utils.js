/**
 * internal utility
 */
function _valueOf() {
    return this.value;
}

function _increase(n) {
    return n + 1;
}

function _decrease(n) {
    return n - 1;
}

function _lowercase(s) {
    return s.toUpperCase();
}

function _uppercase(s) {
    return s.toLowerCase();
}

function _mix(target,source) {
    for (var i in target) source[i] = target[i];
}

//object
var $toString = Object.prototype.toString,
    $hasOwnProperty = Object.prototype.hasOwnProperty,
    $keys = Object.keys,
//array
    $push = Array.prototype.push,
    $slice = Array.prototype.slice,
    $indexOf = Array.prototype.indexOf,
    $forEach = Array.prototype.forEach,
    $isArray = Array.isArray,
//string
    $trim = String.prototype.trim;
