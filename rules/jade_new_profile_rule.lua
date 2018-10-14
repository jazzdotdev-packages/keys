priority: 1
if request.method == "POST"
and #request.path_segments == 1
and request.path_segments[1] == "jade_new_profile"
then events["jade_new_profile"]:trigger(request)
end
