require_relative "test_helper"

class AppTest < Minitest::Test
  include Rack::Test::Methods

  def setup
    Adventure::Story.delete_all
    Adventure::Step.delete_all
  end

  def story
    @story ||= Adventure::Story.create fixture("request-body_story-create.json")
  end

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

  def patch_with_auth(path, data)
    auth_action
    patch(path, data.to_json)
  end

  def fixture(name)
    path = File.expand_path(File.join(__FILE__, "..", "..", "..", "client", "test", "mocks", name))
    JSON.parse(File.read(path)).except("id")
  end

  def session
    @session ||= Adventure::Session.create!(token: SecureRandom.hex)
  end

  def auth_action
    header "AUTHORIZATION", "token #{session.token}"
    header "Content-Type", "application/json"
  end

  def test_can_login
    prev_count = Adventure::Session.count
    response = post("/users/login")

    assert response
    assert_equal(String, JSON.parse(response.body)["token"].class)
    assert_equal(prev_count + 1, Adventure::Session.count)
  end

  def test_can_get_a_single_user
    response = get_with_auth("/users/#{session.id}")

    assert_equal(Hash, JSON.parse(response.body).class)
  end

  def test_can_create_story
    prev_count = Adventure::Story.count
    response = post_with_auth("/adventure", fixture("request-body_story-create.json"))

    assert response
    body = JSON.parse(response.body)
    assert_equal(String, body["title"].class)
    assert_equal(Adventure::Story.find(body["id"]).steps.first.id, body["first_step_id"])
    assert_equal(prev_count + 1, Adventure::Story.count)
  end

  def test_can_get_all_adventure
    story
    response = get_with_auth("/adventure")

    assert response
    body = JSON.parse(response.body)
    assert_equal(Array, body.class)
    assert_equal("Foobar", body.first["title"])
  end

  def test_can_get_a_single_story
    response = get_with_auth("/adventure/#{story.id}")

    assert_equal(Hash, JSON.parse(response.body).class)
    assert_equal(Array, JSON.parse(response.body)["steps"].class)
    assert_equal(Hash, JSON.parse(response.body)["steps"].first.class)
  end

  def test_can_destroy_story
    story
    prev_count = Adventure::Story.count
    response = destroy_with_auth("/adventure/#{story.id}")

    assert response
    assert_equal(String, JSON.parse(response.body)["title"].class)
    assert_equal(prev_count - 1, Adventure::Story.count)
  end

  def test_can_handle_bad_story
    prev_count = Adventure::Story.count
    response = post_with_auth("/adventure", title: "")

    refute response.ok?
    response_data = JSON.parse(response.body)
    assert_equal(Hash, response_data["errors"].class)

    # {"errors" : {"title" : "can't be blank}}
    assert_equal("title", response_data["errors"].first.first)
    assert_equal(prev_count, Adventure::Story.count)
  end

  def test_can_get_a_adventure_steps
    response = get_with_auth("/adventure/#{story.id}/steps")

    assert response
    assert_equal(Array, JSON.parse(response.body).class)
  end

  def test_can_get_a_signular_step
    step = story.steps.create(fixture("single-step.json"))
    response = get_with_auth("/adventure/#{story.id}/steps/#{step.id}")

    assert response
    assert_equal(Hash, JSON.parse(response.body).class)
  end

  def test_can_update_a_signular_step
    step = story.steps.create(fixture("single-step.json"))
    response = patch_with_auth("/adventure/#{story.id}/steps/#{step.id}", body: "blah")

    assert response
    payload = JSON.parse(response.body)
    assert_equal(Hash, payload.class)
    assert_equal("blah", payload["body"])
  end

  def test_can_destroy_a_signular_step
    step = story.steps.create(fixture("single-step.json"))
    response = destroy_with_auth("/adventure/#{story.id}/steps/#{step.id}")

    assert response
    payload = JSON.parse(response.body)
    assert_equal(Hash, payload.class)
    assert_equal("Alice sees a white rabbit, does she follow it or not?", payload["body"])
  end

  def test_can_create_a_adventure_steps
    story
    prev_count = Adventure::Step.count
    response = post_with_auth("/adventure/#{story.id}/steps", body: "bob")

    assert response
    assert_equal(Hash, JSON.parse(response.body).class)
    assert_equal(prev_count + 1, Adventure::Step.count)
  end
end
