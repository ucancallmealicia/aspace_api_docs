class ArchivesSpaceService < Sinatra::Base

  Endpoint.post('/repositories/:repo_id/resources/:id/accept_children')
  .description("Move existing Archival Objects to become children of a Resource. ")
    .example('python') do
      <<-PYTHON
child_uri = '/repositories/2/archival_objects/999'
resource_uri = '/repositories/2/resources/1234'
position = 5
requests.post(api_url + resource_uri + '/accept_children?children[]=' 
                    + child_uri + '&position=' + str(position), headers=headers).json()
      PYTHON
    end
    .documentation do
      <<-DOCS
This route takes the URI of a resource record, the URI of an archival object, and a numerical value for
position and moves the archival object to become the child of a resource at the given position.
      DOCS
    end
  .params(["children", [String], "The children to move to the Resource", :optional => true],
          ["id", Integer, "The ID of the Resource to move children to"],
          ["position", Integer, "The index for the first child to be moved to"],
          ["repo_id", :repo_id])
  .permissions([:update_resource_record])
  .returns([200, :created],
           [400, :error],
           [409, :error]) \
  do
    accept_children_response(Resource, ArchivalObject)
  end
end
