/**
 * Aztec JavaScript Library
 */
//# define :AZTEC, "aztec"
//# include 'version.js';include 'macros.js'
;(function (exports) {
    $AZTEC$ = exports;
    $AZTEC$.config = {
        BuildFlag : {
            native: $NATIVE$,
            test: $TEST$,
            browser: $BROWSER$
        },
        modules : {}
    };
    //#=include 'utils.js'

    //#=include 'lang/enumerable.js'

    //#=include 'lang/string.js'

    //#=include 'lang/array.js'

    //#=include 'lang/object.js'
    
    //#=include 'lang/type.js'
    
    //# if defined :BROWSER
    //#=    include 'browser/browser.js'
    
    //#=    include 'browser/dom.js'
    
    //#=    include 'browser/event.js'

    //#=    include 'ajax/ajax.js'
    //# end
})($IS_UNDEFINED$(exports) ? ($AZTEC$ = { 'version': $VER$ }) : ((exports.version = $VER$) && exports));