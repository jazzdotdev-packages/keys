-- TODO: make it post
if req.method == "GET"
and #req.path_segments == 3
and req.path_segments[1] == "profile"
and req.path_segments[2] == "create"
then
    events["create_profile"]:trigger(req)
end
