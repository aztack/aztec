
//# define(:SELECT)         {|c,a,b| "(#{c} ? #{a} : #{b})"}
//# define(:IS_UNDEFINED)   {|v| "(typeof #{v} === 'undefined')"}
//# define(:IS_FUNCTION)    {|v| "(typeof #{v} === 'function')"}
//# define(:IS_STRING)      {|v| "(typeof #{v} === 'string')"}
//# define(:IS_NULL)        {|v| "(#{v} === null)"}
//# define(:IS_EMPTY)       {|v| "(#{v}.length === 0)"}
//# if defined(:BROWSER)
$SELECT$ = function (condition, valueWhenTrue, valueWhenFalse) {
    return condition ? valueWhenTrue : valueWhenFalse;
};
$IS_UNDEFINED$ = function (expr) {
    return typeof(expr) === 'undefined';
};
$IS_FUNCTION$ = function (expr) {
    return typeof(expr) === 'function';
};
$IS_STRING$ = function (expr) {
    return typeof(expr) === 'string';
};
$IS_NULL$ = function (expr) {
    return expr === null;
};
$IS_EMPTY$ = function (coll) {
    return coll && coll.length === 0;
};
//# end