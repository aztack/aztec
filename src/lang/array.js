/********************
 * Array
 ********************/
//# if defined :NATIVE
//#     define :ARRAY,"Array.prototype"
//# else
//#     define :ARRAY,"aztec.array"
$ARRAY$ = { };
//# end
(function (exports) {
    //#=include_dir './array/*.js'
})($ARRAY$);
