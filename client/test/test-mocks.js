
/**
 * This file mocks out Ajax calls by returning fake data from .json
 * files defined in the test/mocks directory
 *
 *  NOTE: All paths/methods/data in here is made up and incomplete
 *        You should update this file to document your API!
 */

/**
 * This `if` condition restricts the mocking to only happen when the
 * query string includes: debug
 * For example: going to localhost:8080?debug WILL enable mocking
 *              going to localhost:8080 WILL NOT enable mocking
 */
if (window.location.search.match(/[^a-z]debug([^a-z]|$)/i)) {

    $.mockjax({
      url: '/login',
      type: 'POST',
      proxy: 'test/mocks/token.json'
    });

    $.mockjax({
      url: '/stories',
      type: 'GET',
      proxy: 'test/mocks/multi-story.json'
    });

    $.mockjax({
      url: '/stories',
      type: 'POST',
      proxy: 'test/mocks/single-story.json'
    });

}
