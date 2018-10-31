priority: 1
input_parameter: "request"

if request.method == "POST"
and #request.path_segments == 1
and request.path_segments[1] == "profile"
then
    events["create_profile"]:trigger(request)
end
