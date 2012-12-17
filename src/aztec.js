/**
 * Aztec JavaScript Library
 * build flags: native:$NATIVE$,test:$TEST$,browser:$BROWSER$
 */
//# define :AZTEC, "aztec"
//# include 'version.js';include 'macros.js'
;(function (exports) {
    if (exports.version) {
        $AZTEC$ = exports;
    }
    //#=include('utils.js')

    //# if defined :NATIVE
    //#     define :STRING,"String.prototype"
    //#     define :ARRAY,"Array.prototype"
    //#     define :OBJECT,"Object.prototype"
    //#     define :TYPE,"aztec.type"
    //# else
    //#     define :STRING,"aztec.string"
    //#     define :ARRAY,"aztec.array"
    //#     define :OBJECT,"aztec.object"
    $STRING$ = {};
    $ARRAY$  = {};
    $OBJECT$ = {};
    $TYPE$   = {};
    //# end
    
    //#=include('lang/string.js')

    //#=include 'lang/array.js'

    //#=include 'lang/object.js'
    
    //#=include 'lang/type.js'
    
    //# if defined(:BROWSER)
    //#=    include 'browser/browser.js'
    
    //#=    include 'browser/dom.js'
    
    //#=    include 'browser/event.js'
    //# end
})($IS_UNDEFINED$(exports) ? ($AZTEC$ = { 'version': '$VER$' }) : exports);