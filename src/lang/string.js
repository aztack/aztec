/********************
 * String
 ********************/
//# if defined :NATIVE
//#     define :STRING,"String.prototype"
//# else
//#     define :STRING,"aztec.string"
$STRING$ = { };
//# end
(function (exports) {
    //#=include_dir './string/*.js'
})($STRING$);
