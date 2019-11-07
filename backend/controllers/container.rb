require_relative 'search'

class ArchivesSpaceService < Sinatra::Base

  Endpoint.post('/repositories/:repo_id/top_containers/batch/location')
    .description("Update location for a batch of top containers")
    .example('shell') do
      <<-SHELL
 curl -H "X-ArchivesSpace-Session: $SESSION" \\
   -d 'ids[]=[1,2,3,4,5]' \\
   -d 'location_uri=locations/1234' \\
   "http://localhost:8089/repositories/2/top_containers/batch/location"
      SHELL
    end
    .example('python') do
      <<-PYTHON
client = ASnakeClient()
client.post('repositories/2/top_containers/batch/location',
            params={ 'ids': [1,2,3,4,5],
                     'location_uri': 'locations/1234' })
      PYTHON
    end
    .documentation do
      <<-DOCS
This route takes the `ids` of one or more containers, and associates the containers
with the location referenced by `location_uri`.
      DOCS
    end
    .params(["ids", [Integer]],
            ["location_uri", String, "The uri of the location"],
            ["repo_id", :repo_id])
    .permissions([:manage_container_record])
    .returns([200, :updated]) \
  do
    result = TopContainer.bulk_update_location(params[:ids], params[:location_uri])
    json_response(result)
  end
end
