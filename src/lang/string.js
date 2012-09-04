/**
* String
*/
//# if defined :Native
//#     define :String,"String.prototype"
//# else
//#     define :String,"aztec.string"
$String$ = { };
//# end
(function (exports) {
    //#=include_dir './string/*.js'
})($String$);