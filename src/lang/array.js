/**
 * Array
 */
//# if defined :Native
//#     define :Array,"Array.prototype"
//# else
//#     define :Array,"aztec.array"
$Array$ = { };
//# end
(function (exports) {
    //#=include_dir './array/*.js'
})($Array$);