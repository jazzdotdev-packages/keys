event: ["say_hello"]
priority: 1

local port = ctx.msg.path_segments[2]

local date = tostring(time.now())
local body = '{"title":"Hello Message","type":"msg","text":"Hello"}'

--local signature_string = "date: " .. date .. "\n" .. body
signature_string = "a"
log.trace("signature string", signature_string)

-- from torchbear/src/lua_bindings/crypto/mod.rs at line 129
local key = crypto.sign.load_secret("+qEY1pRSYy7gTfJ58GLrDQTuhgiTf49Cy9yEgvix3vHGkq2b5t55E36RPtVYgnTn+2SF0Of8nEeVOyTvcvlnnQ==")

local signature = key:sign_detached(signature_string)

local signature_header = 'keyId="alice",algorithm="rsa-sha256",signature="' .. signature .. '"'

local response = ClientRequest.build()
    :method("POST")
    :uri("http://localhost:" .. port .. "/")
    :headers({
      ["content-type"] = "application/json",
      ["date"] = date,
      ["signature"] = signature_header,
    })
    :send_with_body(body)

--local inspect = require "inspect"

return {
    headers = {
        ["content-type"] = "application/json",
    },
    body = '{"message":"said hello"}'
}
