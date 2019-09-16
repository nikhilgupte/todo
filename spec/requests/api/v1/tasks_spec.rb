require 'rails_helper'

RSpec.describe Task, type: :request do
  let(:headers) { { "CONTENT_TYPE" => "application/json" } }
  let(:tags) { 3.times.collect { |i| Tag.create(title: "Tag #{i + 1}") } }

  describe 'GET /api/v1/tasks' do
    let(:tasks) do
      tasks = 2.times.collect { |i| Task.create(title: "Task #{i + 1}") }
      tasks.first.tags << tags
      tasks
    end
    before :each do
      tasks
    end
    subject { get api_v1_tasks_path headers: headers }
    it 'returns status code :success' do
      subject
      expect(response).to have_http_status(:success)
    end
    it 'returns the tasks with the associated tags' do
      subject
      data = response.parsed_body['data']
      expect(data.size).to eq(2)
      expect(data.collect { |d| d['type'] }.uniq).to eq(['tasks'])
      expect(data.collect { |d| d['attributes']['title'] }).to include(*tasks.pluck(:title))
      relationships0 = data[0]["relationships"]['tags']['data']
      expect(relationships0.collect { |d| d['type'] }.uniq).to eq(['tags'])
      expect(relationships0.collect { |d| d['id'] }).to include(*tags.pluck(:id).collect(&:to_s))
    end
  end

  describe 'POST /api/v1/tasks' do
    subject { post api_v1_tasks_path, params: payload, headers: headers }
    context "with valid data" do
      let(:payload) do
        {
          "data" => {
            "type" => "undefined",
            "id" => "undefined",
            "attributes" => {
              "title" => "Laundry"
            }
          }
        }.to_json
      end

      it "returns http status :created" do
        subject
        expect(response).to have_http_status(:created)
      end
      it "creates the task" do
        expect { subject }.to change { Task.count }.by(1)
        expect(Task.last.title).to eq('Laundry')
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

  describe 'PATCH /api/v1/tasks/:id' do
    let(:task) do
      Task.create(title: 'Task 1').tap do |task|
        task.tags << tags
      end
    end
    subject { patch api_v1_task_path(task.id), params: payload, headers: headers }
    context "with valid data" do
      let(:new_tag_names) { %w[apple banana] }
      let(:payload) do
        {
          "data" => {
            "type" => "tasks",
            "id" => task.id.to_s,
            "attributes" => {
              "title" => "Updated",
              "tags" => new_tag_names
            }
          }
        }.to_json
      end

      it "returns http status :success" do
        subject
        expect(response).to have_http_status(:success)
      end
      it "updates the task" do
        subject
        expect(task.reload.title).to eq('Updated')
        expect(task.reload.tags.pluck(:title)).to include(*new_tag_names)
      end
    end

    context "with invalid data" do
      let(:payload) do
        {
          "data" => {
            "type" => "task",
            "id" => task.id.to_s,
            "attributes" => {
              "title" => "Task 2"
            }
          }
        }.to_json
      end

      before :each do
        Task.create(title: 'Task 2')
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

  describe 'DELETE /api/v1/tasks/:id' do
    let(:task) do
      Task.create!(title: 'Task 1').tap do |task|
        task.tags << tags
      end
    end
    before { task }
    subject { delete api_v1_task_path(task.id), headers: headers }
    it 'returns status code :success' do
      subject
      expect(response).to have_http_status(:success)
    end
    it 'deletes the task' do
      expect { subject }.to change { Task.count }.by(-1)
    end
  end
end
