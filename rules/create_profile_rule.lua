priority = 1
input_parameter = "request"
events_table = ["create_profile"]

request.method == "POST"
and #request.path_segments == 1
and request.path_segments[1] == "profile"
