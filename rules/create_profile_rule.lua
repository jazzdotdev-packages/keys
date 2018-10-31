priority: 1
input_parameter: "request"
events_table: ["create_profile"]

if request.method == "POST"
and #request.path_segments == 1
and request.path_segments[1] == "profile"
then
    events[events_table[1]]:trigger(events_parameters)
end
