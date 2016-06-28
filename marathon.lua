der.content_type = 'application/json'
local cjson = require "cjson"

local json = cjson.encode({
    foo = "bar",
    some_object = {},
    some_array = cjson.empty_array
})

ngx.say(json)

