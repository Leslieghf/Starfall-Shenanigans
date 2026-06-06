local Cache = {}

function Cache.new(init, refreshInterval)
    local cache = {
        dirty = true,
        value = nil,
        init = init,
        refreshInterval = refreshInterval,
        lastRefreshAt = nil
    }

    function cache:shouldRefresh()
        if self.dirty then return true end
        if not self.refreshInterval then return false end

        local now = timer.curtime()
        return not self.lastRefreshAt or now - self.lastRefreshAt >= self.refreshInterval
    end

    function cache:refresh(...)
        self.value = self.init(...)
        self.dirty = false
        self.lastRefreshAt = timer.curtime()
    end

    function cache:get()
        if self.dirty then error("Cache was read before refresh") end

        return self.value
    end

    function cache:invalidate()
        self.dirty = true
    end

    return cache
end

return Cache
