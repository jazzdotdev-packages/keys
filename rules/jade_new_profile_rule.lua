priority: 1

if 
  request.method == "POST"
  and #request.path_segments == 1
  and request.path_segments[1] == "jade_new_profile"
  -- log.trace("[rule] jade_new_profile evaluated as TRUE")
    
  then events["jade_new_profile"]:trigger(request)
end
