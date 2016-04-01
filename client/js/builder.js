(function(ns) {
    'use strict';

    ns.builder = {};

    // cached elements
    var storyList = $('#story-list');
    var createStory = $('#create-story');
    var editStory = $('#edit-story');

    ns.builder.init = function builderInit() {
        storyList.on('click', '.edit-story', function initEdit(e) {
            e.preventDefault();
            // TODO
        });
    };

    ns.builder.loadStoryList = function loadStoryList() {
        $.ajax({
            url: '/stories',
            type: 'get',
            dataType: 'json',
            success: renderStoryList,
            error: function(xhr) {
                console.error(xhr);
                ns.showMessage('Unable to retrieve story list from server.');
            }
        });
    };

    function renderStoryList(stories) {
        storyList.show();

        if (Array.isArray(stories)) {
            stories.forEach(function(story) {
                storyList.find('ul')
                    .append('<li>')
                    .find('li:last-child')
                        .append(story.title)
                        .append(
                            $('<a>').attr('href', '#' + story.id).addClass('edit-story').text('edit')
                        );
            });
        }
    }


    window.cyoa = ns;
})(window.cyoa || {});
