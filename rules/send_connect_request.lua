priority = 1
input_parameter = "request"
events_table = ["send_connect_request"]

request.method == "GET"
and #request.path_segments == 0
and request.query.connect
