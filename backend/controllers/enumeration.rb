class ArchivesSpaceService < Sinatra::Base

  Endpoint.post('/config/enumeration_values/:enum_val_id/position')
    .description("Update the position of an ennumeration value")
    .example('python') do
      <<-PYTHON
enum_val_uri = '/config/enumeration_values/1234'
new_position = 5
requests.post(api_url + enum_val_uri + '/position?position=' + str(new_position), headers=headers).json()
      PYTHON
    end
    .documentation do
      <<-DOCS
This route takes the uri of an enumeration value and a numerical value and updates the position of the enumeration
to the given value.
      DOCS
    end
    .params(["enum_val_id", Integer, "The ID of the enumeration value to update"],
            ["position", Integer, "The target position in the value list"])
    .permissions([:update_enumeration_record])
    .returns([200, :updated],
             [400, :error]) \
  do
    obj = EnumerationValue.get_or_die(params[:enum_val_id])
    obj.update_position_only(params[:position])
    updated_response( obj.refresh )
  end
end
