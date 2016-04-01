(function(ns) {
    'use strict';

    ns.user = {};  // local module namespace

    ns.user.init = function userInit() {
        $('#login').submit(function loginSubmitted(e) {
            e.preventDefault();
            ns.user.login(function loginSuccess(err) {
                if (!err) {
                    $('#login').hide();
                    $('main > nav').show();
                }
            });
        });
    };

    ns.user.login = function doLogin(cb) {
        cb = cb || function(){};
        $.ajax({
            url: '/login',
            type: 'POST',
            dataType: 'json',
            success: function loginSuccess(data) {
                console.info('login?', data);
                ns.user.token = data.token;
                if (ns.user.token) {
                    ns.showMessage('You have been logged in.');
                } else {
                    ns.showMessage('There was a problem logging you in.');
                }
                cb();
            },
            error: function loginFail(xhr) {
                console.error(xhr);
                ns.showMessage('There was a problem logging you in.');
                cb(xhr.status);
            }
        });
    };

    window.cyoa = ns;
})(window.cyoa || {});
