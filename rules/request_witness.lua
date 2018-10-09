if req.method == "GET"
and #req.path_segments == 3
and req.path_segments[1]:match("%a+") -- TODO: make it a known type, not just any word
and req.path_segments[2]:match(utils.uuid_pattern)
and req.path_segments[3] == "witness"
then
    events["witness_request"]:trigger(req)
end
