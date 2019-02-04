priority = 1
input_parameter = "request"
events_table = ["connect_profile"]

request.method == "GET"
and #request.path_segments == 0
and request.query.connect
and #request.query.connect == 0
