(function(ns) {
    'use strict';

    ns.builder = {};

    var loadedStories;

    // cached elements
    var storyList = $('#story-list');
    var createStory = $('#create-story');
    var editStory = $('#edit-story');
    var storyIdElem = editStory.find('.story-id');
    var createStepForm = $('.create-story-step');
    var currentSteps = $('.current-steps');

    ns.builder.init = function builderInit() {
        storyList.on('click', '.edit-story', initEdit);
        createStory.find('form').submit(showCreate);
        $('.show-create-step').click(function toggleStepCreation() { createStepForm.toggle(); });
        currentSteps.on('submit', 'form', gatherUpdateFormData);
    };

    function initEdit(e) {
        e.preventDefault();
        var id = Number($(this).attr('href').substr(1));
        var story = loadedStories.filter(function findStory(data) {
            return (data.id === id);
        })[0];
        if (story) {
            ns.views.hide();
            storyIdElem.val(id);
            ns.builder.initStoryEdit(story);
        } else {
            ns.showMessage('Unable to edit story, I don\'t know that one...');
        }
    }

    function showCreate(e) {
        e.preventDefault();
        ns.builder.createStory( $(this).find(':text').val(), function createDone(data) {
            if (data) {
                ns.views.hide();
                createStory.find(':text').val('');
                ns.builder.initStoryEdit(data);
            }
        } );
    }

    ns.builder.loadStoryList = function loadStoryList() {
        $.ajax({
            url: '/stories',
            type: 'get',
            dataType: 'json',
            success: function loadStorySuccess(data) {
                loadedStories = data;
                renderStoryList(data);
            },
            error: function loadStoryError(xhr) {
                console.error(xhr);
                ns.showMessage('Unable to retrieve story list from server.');
            }
        });
    };

    function renderStoryList(stories) {
        storyList.show();

        if (Array.isArray(stories)) {
            storyList.find('li').remove();
            stories.forEach(function renderStory(story) {
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
            contentType: 'application/json',
            data: JSON.stringify({ title: title }),
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
        editStory.find('.story-name').text(data.title);
        createStepForm.find('.story-id').val(data.id);
        loadStorySteps(data);
    };

    function loadStorySteps(story) {
        $.ajax({
            url: '/stories/' + story.id + '/steps',
            type: 'GET',
            dataType: 'json',
            success: function stepsLoaded(data) {
                console.log('loaded steps:', data);
                renderSteps(data, story);
            },
            error: function stepLoadError(xhr) {
                console.error(xhr);
                ns.showMessage('Sorry, I was not able to load the steps for this story!');
            }
        });
    }

    function renderSteps(steps, story) {
        currentSteps.find('li').remove();
        steps.forEach(function renderStep(step) {
            currentSteps.append(getStepElement(step));
        });
    }

    function getStepElement(step) {
        var newStep = $('<li>');
        newStep
            .append( '<h4>Step ID: <span class="step-id">' + step.id + '</span></h4>' )
            .append('<form>')
            .find('form')
                .addClass('edit-story-step')
                .append('<input type="hidden" name="id" value="' + step.id + '">')
                .append('<input type="hidden" name="story_id" value="' + step.story_id + '">')
                .append(
                    $('<fieldset>')
                        .append('<h4>Step Text</h4>')
                        .append('<textarea class="step-text" name="body" required>' + step.body + '</textarea>')
                )
                .append(
                    $('<fieldset>')
                        .append('<label>Is this a story-ending step?</label>')
                        .append('<input type="radio" name="termination" value="1" checked="' + ((step.termination) ? 'checked' : '') + '">')
                        .append(' Yes ')
                        .append('<input type="radio" name="termination" value="0" checked="' + ((step.termination) ? '' : 'checked') + '">')
                        .append(' No ')
                )
                .append(
                    $('<fieldset>')
                        .append('<label>Option A Text</label>')
                        .append('<input type="text" class="step-option-a" name="option_a_text" value="' + (step.option_a_text || '') + '">')
                        .append('<label>Option A Next Step</label>')
                        .append('<input type="text" class="step-option-a-next" name="option_a_step_id" value="' + (step.option_a_step_id || '') + '">')
                )
                .append(
                    $('<fieldset>')
                        .append('<label>Option B Text</label>')
                        .append('<input type="text" class="step-option-b" name="option_b_text" value="' + (step.option_b_text || '') + '">')
                        .append('<label>Option B Next Step</label>')
                        .append('<input type="text" class="step-option-b-next" name="option_b_step_id" value="' + (step.option_b_step_id || '') + '">')
                )
                .append( $('<fieldset>').append('<input type="submit" value="Update">') );

        return newStep;
    }

    function convertFormToJSON(elem) {
        var data = {};
        $(elem).serializeArray().forEach(function formatFormData(field) {
            data[field.name] = field.value;
            if (field.name === 'termination') {
                data[field.name] = !!Number(field.value);
            }
        });
        return data;
    }

    function gatherUpdateFormData(e) {
        e.preventDefault();
        ns.builder.updateStep(convertFormToJSON(this));
    }

    ns.builder.updateStep = function updateStep(step) {
        $.ajax({
            url: '/stories/' + step.story_id + '/steps/' + step.id,
            type: 'PATCH',
            contentType: 'application/json',
            data: JSON.stringify(step),
            dataType: 'json',
            success: function stepUpdated(data) {
                ns.showMessage('Step updated!');
            },
            error: function stepUpdateError(xhr) {
                console.error(xhr);
                ns.showMessage('Unable to update step.', JSON.stringify(xhr.responseText));
            }
        });
    };

    createStepForm.submit(function gatherStepCreateData(e) {
        e.preventDefault();
        ns.builder.createStep(convertFormToJSON(this));
    });

    ns.builder.createStep = function createStep(step) {
        $.ajax({
            url: '/stories/' + step.story_id + '/steps',
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify(step),
            dataType: 'json',
            success: function stepUpdated(data) {
                currentSteps.append(getStepElement(data));
                ns.showMessage('Step created!');
            },
            error: function stepUpdateError(xhr) {
                console.error(xhr);
                ns.showMessage('Unable to create step.', JSON.stringify(xhr.responseText));
            }
        });
    };


    window.cyoa = ns;
})(window.cyoa || {});
