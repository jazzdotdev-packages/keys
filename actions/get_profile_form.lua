event = ["get_profile_form"]
priority = 1
input_parameters = ["request"]

return {
    headers = {
        ["content-type"] = "text/html; charset=utf-8",
    },
    body = [[
      <html>
        <body>
          <form action="/profile" method="post">
            <input placeholder="name" name="name">
            <input type="submit" vallue="Submit">
          </form>
        <!body>
      </html>
    ]]
}
