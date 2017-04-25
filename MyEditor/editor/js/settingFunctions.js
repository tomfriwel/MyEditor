setFontSizeFamily = function (type, param) {
    var sel = document.selection ? document.selection() :  document.getSelection();
    var pStart = sel.anchorNode,pEnd=sel.extentNode;
    // pStart = $(pStart);
    pStart = pStart.tagName == 'P' ? $(pStart) : $(pStart).parents('p');
    pEnd = pEnd.tagName == 'P' ? $(pEnd) : $(pEnd).parents('p');
    // pEnd = $(pEnd);
    var start=Math.min(pStart.index(),pEnd.index()),end=Math.max(pStart.index(),pEnd.index())
    // var val = $(this).attr('val'),text=$(this).attr('text');
    // var options_div = $(this).parents('.options');

    pStart.css({color:"red"});
    // var cmd = options_div.find('.opt_text').attr('cmd');
    // options_div.find('.opt_text').text(text);
    // for(var i=start;i<end+1;i++){
    //     var p_ele = $('#editor').children().eq(i);
    //     console.log(p_ele);
    //     // if(type=='fontFamily'){
    //         // P.css({fontFamily:param});
    //     // }else{
    //         p_ele.css({fontSize:"29px", color:"red"});
    //     // }
    // }
}


    function getHtmlString(){
        var context = $("#editor").clone();
        var htmlString = $.trim(context.html());
        return htmlString;
    }