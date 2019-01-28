priority = 1
input_parameter = "request"
events_table = ["show_place"]

request.method == "GET"
and
#request.path_segments == 0
and
request.query.place
