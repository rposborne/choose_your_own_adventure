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

post "/login" do
  token = SecureRandom.hex
  Adventure::Session.create!(token: token)
  [200, {token: token}.to_json]
end

get "/stories" do
  Adventure::Story.all.to_json
end

get "/stories/:id" do
  Adventure::Story.find(params["id"]).to_json
end

post "/stories" do
  payload = JSON.parse(request.body.read)
  Adventure::Story.create!(payload).to_json
end

delete "/stories/:id" do
  story = Adventure::Story.find(params["id"])
  story.destroy!.to_json
end

#

get "/stories/:story_id/steps" do
  Adventure::Step.where(story_id: params["story_id"]).to_json
end

post "/stories/:story_id/steps" do
  payload = JSON.parse(request.body.read)
  story = Adventure::Story.find(params["story_id"])
  story.steps.create!(payload).to_json
end

patch "/stories/:story_id/steps/:id" do
  payload = JSON.parse(request.body.read)
  step = Adventure::Step.find(id: params['id'])
  step.update(payload)
  step.to_json
end

delete "/stories/:story_id/steps/:id" do
  story = Adventure::Step.find(params["id"])
  story.destroy!.to_json
end
