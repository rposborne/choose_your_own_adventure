(function(ns) {
    'use strict';

    $(init);  // only initialize once the document is ready

    function init() {
        ns.user.init();
    }

    var msgElem = $('main > .message');
    ns.showMessage = function showMessage(msg) {
        msgElem.text(msg);
        setTimeout(function removeMessage() {
            msgElem.text('');
        }, 5000);
    };


    window.cyoa = ns;
})(window.cyoa || {});
