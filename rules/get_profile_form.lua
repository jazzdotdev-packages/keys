priority: 1
input_parameter: "request"
events_table: ["get_profile_form"]

if request.method == "GET"
and #request.path_segments == 2
and request.path_segments[1] == "profile"
and request.path_segments[2] == "new"
then
    events[events_table[1]]:trigger(events_parameters)
end
