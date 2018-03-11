-- oo with meta method
local function class(super)
    local class_type={}
    class_type.ctor=false
    class_type.super=super
	class_type.new=function(...)
		local obj={}
		setmetatable(obj, class_type)
		do
			local create
			create = function(c,...)
				if c.super then
					create(c.super,...)
				end
				if c.ctor then
					c.ctor(obj,...)
				end
			end

			create(class_type,...)
		end

		return obj
	end
	class_type.bindFunction=function(obj)
		return setmetatable(obj, class_type)
	end
	class_type.checkClass=function(obj)
		if type(obj) == "table" then
			local obj_type = getmetatable(obj)
			return obj_type == class_type
		else
			return false
		end
	end
	class_type.isClass=function(obj)
		if type(obj) == "table" then
			local obj_type = getmetatable(obj)
			while(obj_type) do
				if obj_type == class_type then
					return true
				else
					obj_type = obj_type.super
				end
			end
			return false
		else
			return false
		end
	end

	class_type.__index={}
    if super then
		for k,v in pairs(super) do
			if k:sub(1,2) == "__" and k~= "__index" then
				class_type[k] = v
			end
		end
		for k,v in pairs(super.__index) do
			class_type.__index[k] = v
		end
	end

	setmetatable(class_type, {
		__newindex=function(t,k,v)
			if k:sub(1,2) == "__" then
				rawset(t,k,v)
			else
				t.__index[k] = v
			end
		end,
		__index=function(t,k)
			return t.__index[k]
		end
	})

    return class_type
end

return class
