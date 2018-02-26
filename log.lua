local log = {}

function log.warning(...)
	print("[WARNING]", ...)
end

function log.error(...)
	print("[ERROR]", ...)
end

function log.info(...)
	print("[INFO]", ...)
end

return log
