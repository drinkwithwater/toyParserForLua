-- oo with meta method
function class(super)
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
	class_type.isClass=function(v)
		if type(v) == "table" then
			return class_type == getmetatable(v)
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
		end
	})

    return class_type
end
