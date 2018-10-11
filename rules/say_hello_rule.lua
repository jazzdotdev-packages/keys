if req.method == "GET"
and #req.path_segments == 2
and req.path_segments[1] == "say_hello"
then
  events["say_hello"]:trigger()
end