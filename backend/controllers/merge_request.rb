class ArchivesSpaceService < Sinatra::Base

  Endpoint.post('/merge_requests/subject')
    .description("Carry out a merge request against Subject records. ")
    .example('python') do
      <<-PYTHON
merge_json = {'target': {ref: '/subjects/1234'},
              'victims': [{'ref': '/subjects/5678'}],
              'jsonmodel_type': 'merge_request'}
requests.post(api_url + '/merge_requests/subject', headers=headers, json=merge_json).json()
      PYTHON
    end
    .documentation do
      <<-DOCS
This route merges one or more "victim" subject records into a "target" subject record.
      DOCS
    end
    .params(["merge_request",
             JSONModel(:merge_request), "A merge request",
             :body => true])
    .permissions([:merge_subject_record])
    .returns([200, :updated]) \
  do
    target, victims = parse_references(params[:merge_request])

    ensure_type(target, victims, 'subject')

    Subject.get_or_die(target[:id]).assimilate(victims.map {|v| Subject.get_or_die(v[:id])})

    json_response(:status => "OK")
  end

  Endpoint.post('/merge_requests/agent')
    .description("Carry out a merge request against Agent records. ")
    .example('python') do
      <<-PYTHON
merge_json = {'target': {ref: '/agents/people/1234'},
              'victims': [{'ref': '/agents/people/5678'}],
              'jsonmodel_type': 'merge_request'}
requests.post(api_url + '/merge_requests/agent', headers=headers, json=merge_json).json()
      PYTHON
    end
    .documentation do
      <<-DOCS
This route merges one or more "victim" agent records into a "target" agent record.
      DOCS
    end
    .params(["merge_request",
             JSONModel(:merge_request), "A merge request",
             :body => true])
    .permissions([:merge_agent_record])
    .returns([200, :updated]) \
  do
    target, victims = parse_references(params[:merge_request])

    if (victims.map {|r| r[:type]} + [target[:type]]).any? {|type| !AgentManager.known_agent_type?(type)}
      raise BadParamsException.new(:merge_request => ["Agent merge request can only merge agent records"])
    end

    agent_model = AgentManager.model_for(target[:type])
    agent_model.get_or_die(target[:id]).assimilate(victims.map {|v|
                                                     AgentManager.model_for(v[:type]).get_or_die(v[:id])
                                                   })

    json_response(:status => "OK")
  end

  Endpoint.post('/merge_requests/resource')
    .description("Carry out a merge request against Resource records. ")
    .example('python') do
      <<-PYTHON
merge_json = {'target': {ref: '/repositories/2/resources/1234'},
              'victims': [{'ref': '/repositories/2/resources/5678'}],
              'jsonmodel_type': 'merge_request'}
requests.post(api_url + '/merge_requests/resource', headers=headers, json=merge_json).json()
      PYTHON
    end
    .documentation do
      <<-DOCS
This route merges one or more "victim" resource records into a "target" resource record.
      DOCS
    end
    .params(["repo_id", :repo_id],
            ["merge_request",
             JSONModel(:merge_request), "A merge request",
             :body => true])
    .permissions([:merge_archival_record])
    .returns([200, :updated]) \
  do
    target, victims = parse_references(params[:merge_request])
    repo_uri = JSONModel(:repository).uri_for(params[:repo_id])

    check_repository(target, victims, params[:repo_id])
    ensure_type(target, victims, 'resource')

    Resource.get_or_die(target[:id]).assimilate(victims.map {|v| Resource.get_or_die(v[:id])})

    json_response(:status => "OK")
  end


  Endpoint.post('/merge_requests/digital_object')
    .description("Carry out a merge request against Digital_Object records. ")
    .example('python') do
      <<-PYTHON
merge_json = {'target': {ref: '/repositories/2/digital_objects/1234'},
              'victims': [{'ref': '/repositories/2/digital_objects/5678'},
                          {'ref': '/repositories/2/digital_objects/91011}],
              'jsonmodel_type': 'merge_request'}
requests.post(api_url + '/merge_requests/digital_object', headers=headers, json=merge_json).json()
      PYTHON
    end
    .documentation do
      <<-DOCS
This route merges one or more "victim" digital object records into a "target" digital object record.
      DOCS
    end
    .params(["repo_id", :repo_id],
            ["merge_request",
             JSONModel(:merge_request), "A merge request",
             :body => true])
    .permissions([:merge_archival_record])
    .returns([200, :updated]) \
  do
    target, victims = parse_references(params[:merge_request])
    repo_uri = JSONModel(:repository).uri_for(params[:repo_id])

    check_repository(target, victims, params[:repo_id])
    ensure_type(target, victims, 'digital_object')

    DigitalObject.get_or_die(target[:id]).assimilate(victims.map {|v| DigitalObject.get_or_die(v[:id])})

    json_response(:status => "OK")
  end
end
