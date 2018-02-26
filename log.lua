local log = {}

function log.warning(...)
	print("[WARNING]", ...)
end

function log.error(...)
	print("[ERROR]", ...)
end

function log.info(...)
	print("[info]", ...)
end

return log
