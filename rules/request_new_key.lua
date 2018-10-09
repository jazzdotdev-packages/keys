if
	req.method == "GET"
	and
	req.path:match("/get_keys/?")
	then
    events["key_generation_request"]:trigger(req)
end
