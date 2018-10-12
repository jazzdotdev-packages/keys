if req.method == "POST"
and #req.path_segments == 1
and req.path_segments[1] == "jade_new_profile"
then events["jade_new_profile"]:trigger(req)
end
