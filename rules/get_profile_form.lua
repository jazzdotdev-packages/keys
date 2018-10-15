priority: 1
if request.method == "GET"
and #request.path_segments == 2
and request.path_segments[1] == "profile"
and request.path_segments[2] == "new"
then
    events["get_profile_form"]:trigger(request)
end
