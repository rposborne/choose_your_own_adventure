ENV["RACK_ENV"] ||= 'development'

require "rubygems"
require "bundler/setup"
require "sinatra"
require "json"

require_relative "lib/adventure"


set :static, true
set :public_folder, Proc.new { File.join(root, "..", "client") }

before do
  content_type "application/json"
end

helpers do
  def current_user
    Adventure::Session.where(token: request.env["HTTP_AUTHORIZATION"].split.last).first
  end

  def halt_unless_user
    halt 401, {msg: "go away!"}.to_json unless current_user
  end
end

post "/login" do
  token = SecureRandom.hex
  Adventure::Session.create!(token: token)
  [201, {token: token}.to_json]
end

get "/stories" do
  halt_unless_user

  Adventure::Story.all.to_json
end

get "/stories/:id" do
  halt_unless_user

  Adventure::Story.find(params["id"]).to_json
end

post "/stories" do
  halt_unless_user

  payload = JSON.parse(request.body.read)
  json_body = Adventure::Story.create!(payload).to_json
  [201, json_body]
end

delete "/stories/:id" do
  halt_unless_user

  story = Adventure::Story.find(params["id"])
  [202, story.destroy!.to_json]
end

# STEPS

get "/stories/:story_id/steps" do
  halt_unless_user
  Adventure::Step.where(story_id: params["story_id"]).to_json
end

post "/stories/:story_id/steps" do
  halt_unless_user

  payload = JSON.parse(request.body.read)
  story = Adventure::Story.find(params["story_id"])

  [201, story.steps.create!(payload).to_json]
end

patch "/stories/:story_id/steps/:id" do
  halt_unless_user

  payload = JSON.parse(request.body.read)
  step = Adventure::Step.find(id: params['id'])
  step.update(payload)

  [202, step.to_json]
end

delete "/stories/:story_id/steps/:id" do
  halt_unless_user

  step = Adventure::Step.find(params["id"])
  [202, step.destroy!.to_json]
end
