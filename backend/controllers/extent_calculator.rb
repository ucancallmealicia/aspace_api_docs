class ArchivesSpaceService < Sinatra::Base

  Endpoint.get('/extent_calculator')
  .description("Calculate the extent of an archival object tree")
    .example('python') do
      <<-PYTHON
uri = '/repositories/2/resources/1234'
extent_calc = requests.get(api_url + '/extent_calculator?record_uri=' + uri, headers=headers).json()
print(extent_calc)
      PYTHON
    end
    .documentation do
      <<-DOCS
This route takes the uri of a resource record and calculates the total extent of
its archival object tree.
      DOCS
    end
  .params(["record_uri", String, "The uri of the object"],
          ["unit", String, "The unit of measurement to use", :optional => true])
  .permissions([])
  .returns([200, "Calculation results"]) \
  do
    parsed = JSONModel.parse_reference(params[:record_uri])
    RequestContext.open(:repo_id => JSONModel(:repository).id_for(parsed[:repository])) do
      obj = Kernel.const_get(parsed[:type].to_s.camelize)[parsed[:id]]
      ext_cal = ExtentCalculator.new(obj)
      ext_cal.units = params[:unit].intern if params[:unit]
      json_response(ext_cal.to_hash)
    end
  end

end
