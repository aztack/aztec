var enumerable = aztec,enumerable,
    forEach = enumerable.forEach,
    inject = enumerable.inject;
assertTrue((function(){
    var result = '';
    forEach([1,2,3,{}],function(e){
        result += String(e);
    });
    return result;
})() == '123[object Object]');

assertTrue((function(){
    return inject([1,2,3,4,5,6,7,9],1,function(sum,i){
        sum = sum + 1;
        return sum;
    });
})() === 56);