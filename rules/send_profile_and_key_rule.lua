if req.method == "GET"
and #req.path_segments == 2
and req.path_segments[1]:match("send_profile") -- TODO: make it a known type, not just any word
then
    events["send_profile_and_key"]:trigger(req)
end
