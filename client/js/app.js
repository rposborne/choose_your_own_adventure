(function(ns) {
    'use strict';

    $(init);  // only initialize once the document is ready

    var views = $('.view');

    function init() {
        ns.user.init();
        ns.builder.init();
        initNav();
    }

    var msgElem = $('main > .message');
    ns.showMessage = function showMessage(msg) {
        msgElem.text(msg);
        setTimeout(function removeMessage() {
            msgElem.text('');
        }, 5000);
    };

    function initNav() {
        $('.list-stories').click(function showStoryList(e) {
            e.preventDefault();
            views.hide();
            ns.builder.loadStoryList();
        });
    }


    window.cyoa = ns;
})(window.cyoa || {});
