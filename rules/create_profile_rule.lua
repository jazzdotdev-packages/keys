priority: 1
-- TODO: make it post
if request.method == "GET"
and #request.path_segments == 3
and request.path_segments[1] == "profile"
and request.path_segments[2] == "create"
then
    events["create_profile"]:trigger(request)
end
