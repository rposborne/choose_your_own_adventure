ENV["RACK_ENV"] ||= "development"

require "rubygems"
require "bundler/setup"
require "sinatra"
require "json"
require "rack/cors"

require_relative "lib/adventure"

set :static, true
set :public_folder, proc { File.join(root, "..", "client") }

use Rack::Cors do
  allow do
    origins "*"
    resource "/**/*", headers: :any, methods: [:get, :post, :options, :patch, :put]
  end
end

before do
  content_type "application/json"
end

before "/adventure/**/*" do
  halt_unless_user
end

helpers do
  def current_user
    Adventure::Session.where(token: request.env["HTTP_AUTHORIZATION"].to_s.split.last).first
  end

  def halt_unless_user
    halt 401, { msg: "go away!" }.to_json unless current_user
  end

  def respond_with_or_errors(code, obj)
    if obj.valid?
      [code, obj.to_json]
    else
      [422, { errors: obj.errors.to_h }.to_json]
    end
  end
end

get "/" do
  content_type "text/html"
  File.read(File.join(settings.root, "..", "client", "index.html"))
end

get "/users/:id" do
  session = Adventure::Session.find(params["id"])
  session.to_json
end

post "/users/login" do
  token = SecureRandom.hex
  Adventure::Session.create(token: token)
  [201, { token: token }.to_json]
end

get "/adventure" do
  Adventure::Story.all.to_json
end

get "/adventure/:id" do
  story = Adventure::Story.find(params["id"])
  story.as_json(include: :steps).to_json
end

post "/adventure" do
  payload = JSON.parse(request.body.read)
  story = Adventure::Story.create(payload)

  respond_with_or_errors(201, story)
end

delete "/adventure/:id" do
  story = Adventure::Story.find(params["id"])
  story.destroy

  respond_with_or_errors(202, story)
end

# STEPS

get "/adventure/:story_id/steps" do
  Adventure::Step.where(story_id: params["story_id"]).to_json
end

post "/adventure/:story_id/steps" do
  payload = JSON.parse(request.body.read)
  story = Adventure::Story.find(params["story_id"])
  step = story.steps.create(payload)

  respond_with_or_errors(201, step)
end

get "/adventure/:story_id/steps/:id" do
  step = Adventure::Step.find(params["id"])

  respond_with_or_errors(200, step)
end

get "/step/:id" do
  step = Adventure::Step.find(params["id"])

  respond_with_or_errors(200, step)
end

get "/steps/:id" do
  step = Adventure::Step.find(params["id"])

  respond_with_or_errors(200, step)
end

get "/step/next" do
  step = Adventure::Step.find(current_user.current_step)

  respond_with_or_errors(200, step)
end

patch "/adventure/:story_id/steps/:id" do
  payload = JSON.parse(request.body.read)
  step = Adventure::Step.find(params["id"])
  step.update(payload)

  respond_with_or_errors(202, step)
end

delete  "/adventure/:story_id/steps/:id" do
  step = Adventure::Step.find(params["id"])
  step.destroy

  respond_with_or_errors(202, step)
end


options "/*" do

end
