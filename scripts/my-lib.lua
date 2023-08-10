local inAPI = require('syslib.api')

local lib = {}

function lib:readperfcounters(arg, req, hlp)
    arg = arg or {}
    local now = syslib.currenttime()
    local startTime
    if type(arg.starttime) == 'string' then
        -- Use starttime supplied by the caller.
        startTime = arg.starttime
    else
        -- Fallback to a default relative starttime
        startTime = syslib.gettime(now-(5*60*1000))
    end
    local endTime = syslib.gettime(now)
    local qry = {
        start_time = startTime,
        end_time = endTime,
        intervals_no = 100,
        items = {
            {
                p = "/System/VMGOTSELJO1.Performance.CPU",
                aggregate = "AGG_TYPE_INTERPOLATIVE"
            }
        }
    }
    return inAPI:readhistoricaldata(qry, req, hlp)
end


function lib:readtag(arg, req, hlp)
    arg = arg or {}
    local now = syslib.currenttime()
    local startTime
    if type(arg.starttime) == 'string' then
        -- Use starttime supplied by the caller.
        startTime = arg.starttime
    else
        -- Fallback to a default relative starttime
        startTime = syslib.gettime(now-(5*60*1000))
    end
    local endTime = syslib.gettime(now)
	local tagName
	if type(arg.tagname) == 'string' then
        -- Use starttime supplied by the caller.
        tagName = arg.tagname
    else
        -- Fallback to a default relative starttime
        tagName = "DC4711"
    end
    local qry = {
        start_time = startTime,
        end_time = endTime,
        intervals_no = 10,
        items = {
            {
				p = "/System/VMGOTSELJO1/Examples/Demo Data/Process Data/" .. tagName,
                aggregate = "AGG_TYPE_INTERPOLATIVE"
            }
        }
    }
    return inAPI:readhistoricaldata(qry, req, hlp)
end


function lib:readpath(arg, req, hlp)
    arg = arg or {}
    local now = syslib.currenttime()
    local startTime
    if type(arg.starttime) == 'string' then
        -- Use starttime supplied by the caller.
        startTime = arg.starttime
    else
        -- Fallback to a default relative starttime
        startTime = syslib.gettime(now-(5*60*1000))
    end
    local endTime = syslib.gettime(now)
	local tagName

	local urldecode = function(url)
  return (url:gsub("%%(%x%x)", function(x)
    return string.char(tonumber(x, 16))
    end))
end

	if type(req.path) == 'string' then
        -- Use starttime supplied by the caller.
        tagName = urldecode(req.path)
    else
        -- Fallback to a default relative starttime
        tagName = "/Demo Data/Process Data/DC4711"
    end
    local qry = {
        start_time = startTime,
        end_time = endTime,
        intervals_no = 10,
        items = {
            {
				p = "/System/VMGOTSELJO1/Examples" .. tagName,
                aggregate = "AGG_TYPE_INTERPOLATIVE"
            }
        }
    }
    return inAPI:readhistoricaldata(qry, req, hlp)
end

function lib.readhist(_, arg, req, hlp)
    arg = arg or {}
    local now = syslib.currenttime()
    local startTime
    if type(arg.starttime) == 'string' then
        -- Use starttime supplied by the caller
        startTime = arg.starttime
    else
        -- Fallback to a default relative starttime
        startTime = syslib.gettime(now-(5*24*60*60*1000))
    end
    local endTime = syslib.gettime(now)
    local qry = {
        start_time = startTime,
        end_time = endTime,
        items = {
            {
                p = "/System/VMGOTSELJO1/Examples/Demo Data/Process Data/DC4711"
            }
        }
    }

    local respData = {}
    local res = inAPI:readrawhistoricaldata(qry, req, hlp)
    local rawData = res.data or {}
    local histData = rawData.historical_data or {}
    local queryData = histData.query_data or {}
    if #queryData > 0 then
        queryData = queryData[1]
        local items = queryData.items or {}
        if #items > 0 then
            items = items[1]
            for i,t in ipairs(items.t) do
                local value = items.v[i]
                local timestampISO = syslib.gettime(t)
                local row = ("%s,%s"):format(timestampISO, value)
                table.insert(respData, row)
            end
        end
    end
    local result = table.concat(respData, '\n')
    return hlp:createResponse(result, nil, 200, { ["Content-Type"] = "text/csv" })
end

return lib