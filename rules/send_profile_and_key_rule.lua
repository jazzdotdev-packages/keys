priority: 1
input_parameter: "request"

if request.method == "GET"
and #request.path_segments == 2
and request.path_segments[1]:match("send_profile") -- TODO: make it a known type, not just any word
and uuid.check(request.path_segments[2])
then
    events["send_profile_and_key"]:trigger(request)
end
