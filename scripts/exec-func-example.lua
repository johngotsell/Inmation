local lib = {}

function lib:say_hello(arg)
    local _arg = arg or {} -- in case no argument is set
    local name = _arg.name or 'unknown'
    local msg = string.format("Hello %s", name)
    return msg
end

return lib