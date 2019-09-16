require 'rails_helper'

RSpec.describe Tag, type: :request do
  let(:headers) { { "CONTENT_TYPE" => "application/json" } }

  describe 'GET /api/v1/tags' do
    let(:tags) { 3.times.collect { |i| Tag.create(title: "Tag #{i + 1}") } }
    before :each do
      tags
    end
    subject { get api_v1_tags_path headers: headers }
    it 'returns status code 200' do
      subject
      expect(response).to have_http_status(:success)
    end
    it 'returns the tasks' do
      subject
      data = response.parsed_body['data']
      expect(data.size).to eq(3)
      expect(data.collect { |d| d['type'] }.uniq).to eq(['tags'])
      expect(data.collect { |d| d['attributes']['title'] }).to include(*tags.pluck(:title))
    end
  end

  describe 'POST /api/v1/tags' do
    subject { post api_v1_tags_path, params: payload, headers: headers }
    context "with valid data" do
      let(:payload) do
        {
          "data" => {
            "type" => "undefined",
            "id" => "undefined",
            "attributes" => {
              "title" => "Someday"
            }
          }
        }.to_json
      end

      it "returns http status :created" do
        subject
        expect(response).to have_http_status(:created)
      end
      it "creates the tag" do
        expect { subject }.to change { Tag.count }.by(1)
        expect(Tag.last.title).to eq('Someday')
      end
    end

    context "with invalid data" do
      let(:payload) do
        {
          "data" => {
            "type" => "undefined",
            "id" => "undefined",
            "attributes" => {
              "title" => ""
            }
          }
        }.to_json
      end

      it "returns http status :unprocessable_entity" do
        subject
        expect(response).to have_http_status(:unprocessable_entity)
      end
      it "returns the error object" do
        subject
        expect(response.body)
          .to be_json_eql({ "errors" => [{ "source" => { "pointer" => "/data/attributes/title" }, "detail" => "can't be blank" }] }.to_json)
      end
    end
  end

  describe 'PATCH /api/v1/tags/:id' do
    let(:tag) { Tag.create(title: 'Tag 1') }
    subject { patch api_v1_tag_path(tag.id), params: payload, headers: headers }
    context "with valid data" do
      let(:payload) do
        {
          "data" => {
            "type" => "tags",
            "id" => tag.id.to_s,
            "attributes" => {
              "title" => "Updated"
            }
          }
        }.to_json
      end

      it "returns http status :success" do
        subject
        expect(response).to have_http_status(:success)
      end
      it "updates the tag" do
        subject
        expect(tag.reload.title).to eq('Updated')
      end
    end

    context "with invalid data" do
      let(:payload) do
        {
          "data" => {
            "type" => "tag",
            "id" => tag.id.to_s,
            "attributes" => {
              "title" => "Tag 2"
            }
          }
        }.to_json
      end

      before :each do
        Tag.create(title: 'Tag 2')
      end
      it "returns http status :unprocessable_entity" do
        subject
        expect(response).to have_http_status(:unprocessable_entity)
      end
      it "returns the error object" do
        subject
        expect(response.body)
          .to be_json_eql({ "errors" => [{ "source" => { "pointer" => "/data/attributes/title" }, "detail" => "has already been taken" }] }.to_json)
      end
    end
  end
end
