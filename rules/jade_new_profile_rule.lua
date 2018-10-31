priority: 1
input_parameter: "request"
events_table: ["jade_new_profile"]

if 
  request.method == "POST"
  and #request.path_segments == 1
  and request.path_segments[1] == "jade_new_profile"
  -- log.trace("[rule] jade_new_profile evaluated as TRUE")
    
  then
    events[events_table[1]]:trigger(request)
end
