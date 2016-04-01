require_relative "test_helper"

class AppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def post_with_auth(path, data)
    auth_action
    post(path, data.to_json)
  end

  def get_with_auth(path)
    auth_action
    get(path)
  end

  def destroy_with_auth(path)
    auth_action
    delete(path)
  end

  def auth_action
    @session ||= Adventure::Session.create!(token: SecureRandom.hex)
    header 'AUTHORIZATION', "token #{@session.token}"
    header 'Content-Type', "application/json"
  end

  def test_can_login
    prev_count = Adventure::Session.count
    response = post("login")

    assert response
    assert_equal(String, JSON.parse(response.body)["token"].class)
    assert_equal(prev_count + 1, Adventure::Session.count)
  end

  def test_can_create_story
    prev_count = Adventure::Story.count
    response = post_with_auth("/stories", title: 'thing')

    assert response
    assert_equal(String, JSON.parse(response.body)["title"].class)
    assert_equal(prev_count + 1, Adventure::Story.count)
  end

  def test_can_get_all_stories
    Adventure::Story.create(title: "bob")
    response = get_with_auth("/stories")

    assert response
    body = JSON.parse(response.body)
    assert_equal(Array, body.class)
    assert_equal("bob", body.first["title"])
  end


  def test_can_destroy_story
    story = Adventure::Story.create(title: "bob")
    prev_count = Adventure::Story.count
    response = destroy_with_auth("/stories/#{story.id}")

    assert response
    assert_equal(String, JSON.parse(response.body)["title"].class)
    assert_equal(prev_count - 1, Adventure::Story.count)
  end

  def test_can_handle_bad_story
    prev_count = Adventure::Story.count
    response = post_with_auth("/stories", {title: ""})

    refute response.ok?
    response_data = JSON.parse(response.body)
    assert_equal(Hash, response_data["errors"].class)

    # {"errors" : {"title" : "can't be blank}}
    assert_equal("title", response_data["errors"].first.first)
    assert_equal(prev_count, Adventure::Story.count)
  end

  def test_can_get_a_stories_steps
    story = Adventure::Story.create(title: "bob")
    response = get_with_auth("/stories/#{story.id}/steps")

    assert response
    assert_equal(Array, JSON.parse(response.body).class)
  end

  def test_can_create_a_stories_steps
    story = Adventure::Story.create(title: "bob")
    prev_count = Adventure::Step.count
    response = post_with_auth("/stories/#{story.id}/steps", {body: "bob"})

    assert response
    assert_equal(Hash, JSON.parse(response.body).class)
    assert_equal(prev_count + 1, Adventure::Step.count)
  end
end
