local PipelineClasses = {}

function PipelineClasses.newPipeline(name, interval)
    local pipeline = {
        name = name,
        interval = interval,
        queue = {},
        running = false
    }

    function pipeline:enqueue(run, complete)
        table.insert(self.queue, {
            run = run,
            complete = complete
        })
    end

    function pipeline:processOne()
        if #self.queue == 0 then return end

        local job = table.remove(self.queue, 1)
        local result = job.run()

        if job.complete then
            job.complete(result)
        end

        return true
    end

    function pipeline:processWhile(canProcess)
        local processed = 0

        while #self.queue > 0 and canProcess() do
            self:processOne()
            processed = processed + 1
        end

        return processed
    end

    function pipeline:start()
        if self.running then return end
        if not self.interval then error("Pipeline interval is required for timer-driven pipelines") end

        timer.create(self.name, self.interval, 0, function()
            self:processOne()
        end)

        self.running = true
    end

    function pipeline:stop()
        if not self.running then return end

        timer.remove(self.name)
        self.running = false
    end

    function pipeline:clear()
        self.queue = {}
    end

    function pipeline:size()
        return #self.queue
    end

    return pipeline
end

return PipelineClasses
