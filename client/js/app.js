(function(ns) {
    'use strict';

    $(init);  // only initialize once the document is ready

    ns.views = $('.view');

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
        $('nav .list-stories').click(function showStoryList(e) {
            e.preventDefault();
            ns.views.hide();
            ns.builder.loadStoryList();
        });

        $('nav .create-story').click(function showStoryList(e) {
            e.preventDefault();
            ns.views.hide();
            ns.builder.showStoryCreate();
        });
    }


    window.cyoa = ns;
})(window.cyoa || {});
