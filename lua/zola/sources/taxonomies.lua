local source = {}
local Job = require 'plenary.job'

local CompletionItemKind = require('blink.cmp.types').CompletionItemKind
local runtime = require('zola').runtime

function source.new(opts)
    local self = setmetatable({}, { __index = source })
    self.opts = opts
    return self
end

function source:enabled()
    return vim.bo.filetype == 'markdown' and runtime.content_dir ~= nil and runtime.config_file ~= nil and vim.fn.executable 'rg' == 1
end

function source:get_trigger_characters()
    return { '"', "'" }
end

function source.relevant_taxonomy(line, start_col)
    local line_content_preceding = string.sub(line, 0, start_col)
    for _, tax in ipairs(runtime.taxonomies) do
        if string.match(line_content_preceding, '%s*' .. tax .. '%s*=%s*%[') then
            return tax
        end
    end

    return nil
end

function source:get_completions(ctx, callback)
    if runtime.taxonomies == nil then
        local args = { '-U', '-o', '--no-filename', 'taxonomies\\s*=\\s*\\[(.|\\n)*?\\]', runtime.config_file.filename }
        local result = Job:new({
            command = 'rg',
            args = args,
        }):sync(500)
        if not result then
            vim.notify 'could not determine taxonomies using rg...'
            callback()
            return
        end

        local taxonomy_table = table.concat(result, '')
        local taxonomies = {}

        for name in string.gmatch(taxonomy_table, '.*name%s*=%s(%b"")') do
            table.insert(taxonomies, string.sub(name, 2, #name - 1))
        end

        for name in string.gmatch(taxonomy_table, ".*name%s*=%s(%b'')") do
            table.insert(taxonomies, string.sub(name, 2, #name - 1))
        end

        runtime.taxonomies = taxonomies
    end

    local relevant_taxonomy = source.relevant_taxonomy(ctx.bounds.line, ctx.bounds.start_col)
    if not relevant_taxonomy then
        callback()
        return
    end

    local items = {}

    local args = { '-U', '-o', '--no-filename', relevant_taxonomy .. '\\s*=\\s*\\[((.|\\n)*?)\\]', runtime.content_dir.filename }
    local result = Job:new({
        command = 'rg',
        args = args,
    }):sync()
    if not result then
        vim.notify('could not determine ' .. relevant_taxonomy .. ' values using rg...', vim.log.levels.ERROR)
        callback()
        return
    end

    local counts = {}

    for _, line in pairs(result) do
        for val in string.gmatch(line, "%b''") do
            local clean = string.sub(val, 2, #val - 1)
            if counts[clean] == nil then
                counts[clean] = 1
            else
                counts[clean] = counts[clean] + 1
            end
        end
        for val in string.gmatch(line, '%b""') do
            local clean = string.sub(val, 2, #val - 1)
            if counts[clean] == nil then
                counts[clean] = 1
            else
                counts[clean] = counts[clean] + 1
            end
        end
    end

    local counts_sorted = {}
    for n in pairs(counts) do
        table.insert(counts_sorted, n)
    end

    for val, count in pairs(counts) do
        local label = val .. '(' .. count .. ')'
        table.insert(items, { label = label, insertText = val, kind = CompletionItemKind.Text, count = count })
    end
    table.sort(items, function(a, b)
        return a.count > b.count
    end)
    callback {
        items = items,
    }
end

return source
