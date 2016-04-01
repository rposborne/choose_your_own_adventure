(function(ns) {
    'use strict';

    ns.builder = {};

    var loadedStories = {};

    // cached elements
    var storyList = $('#story-list');
    var createStory = $('#create-story');
    var editStory = $('#edit-story');

    ns.builder.init = function builderInit() {
        storyList.on('click', '.edit-story', function initEdit(e) {
            e.preventDefault();
            var id = Number($(this).attr('href').substr(1));
            var story = loadedStories.filter(function findStory(data) {
                return (data.id === id);
            })[0];
            if (story) {
                ns.views.hide();
                ns.builder.initStoryEdit(story);
            } else {
                ns.showMessage('Unable to edit story, I don\'t know that one...');
            }
        });

        createStory.find('form').submit(function doCreate(e) {
            e.preventDefault();
            ns.builder.createStory( $(this).find(':text').val(), function createDone(data) {
                if (data) {
                    ns.views.hide();
                    createStory.find(':text').val('');
                    ns.builder.initStoryEdit(data);
                }
            } );
        });
    };

    ns.builder.loadStoryList = function loadStoryList() {
        $.ajax({
            url: '/stories',
            type: 'get',
            dataType: 'json',
            success: function(data) {
                loadedStories = data;
                renderStoryList(data);
            },
            error: function loadError(xhr) {
                console.error(xhr);
                ns.showMessage('Unable to retrieve story list from server.');
            }
        });
    };

    function renderStoryList(stories) {
        storyList.show();

        if (Array.isArray(stories)) {
            storyList.find('li').remove();
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

    ns.builder.showStoryCreate = function showStoryCreate() {
        createStory.show();
    };

    ns.builder.createStory = function createStory(title, cb) {
        cb = cb || function(){};

        $.ajax({
            url: '/stories',
            type: 'post',
            dataType: 'json',
            success: cb,
            error: function createError(xhr) {
                var errData;
                console.error(xhr);
                if (xhr.status === 400) {
                    ns.showMessage('Problem creating story:', xhr.responseText);
                } else {
                    ns.showMessage('Unable to create story, sorry!');
                }
                cb(null);
            }
        });
    };

    ns.builder.initStoryEdit = function initStoryEdit(data) {
        editStory.show();
        console.log('editing story', data);
    };


    window.cyoa = ns;
})(window.cyoa || {});
