if req.method == "GET"
and #req.path_segments == 1
and req.path_segments[1]:match("send_key") -- TODO: make it a known type, not just any word
then
    events["send_key"]:trigger(req)
end
