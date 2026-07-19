local source = {}

local CompletionItemKind = require('blink.cmp.types').CompletionItemKind

-- `opts` table comes from `sources.providers.your_provider.opts`
-- You may also accept a second argument `config`, to get the full
-- `sources.providers.your_provider` table
function source.new(opts)
    local self = setmetatable({}, { __index = source })
    self.opts = opts
    return self
end

function source:enabled()
    return vim.bo.filetype == 'markdown' and require('zola').runtime.shortcode_dir ~= nil
end

function source:get_trigger_characters()
    return { '{' }
end

function source._label_from_rel_path(path)
    -- just to be sure
    if path == nil then
        return nil
    end

    local label = path
    local label_filered = string.gsub(label, '%.md$', '')
    if label_filered ~= nil then
        label = label_filered
    end

    label_filered = string.gsub(label, '%.html$', '')
    if label_filered ~= nil then
        label = label_filered
    end

    return label
end

function source._should_show(line, start_col)
    local line_content_preceding = string.sub(line, 0, start_col)

    if #line_content_preceding < 2 then
        return false
    end

    -- we're basically searching backward from the cursor. if we find a }}, a ( or a )
    -- we don't have to show completion
    -- if we find a {{ (and thus not one of the previous ones) we're in a short code and should provide completions
    -- if we reach the end of the string we dont' have to

    for i = #line_content_preceding, 2, -1 do
        local substr = string.sub(line_content_preceding, i, i)
        if substr == ')' or substr == '(' then
            return false
        end

        substr = string.sub(line_content_preceding, i - 1, i)

        if substr == '}}' then
            return false
        end
        if substr == '}}' then
            return false
        end
        if substr == '{{' then
            return true
        end
    end
    return false
end

function source._discover_files(root)
    local path
    if type(root) == 'string' then
        path = root
    elseif type(root) == 'table' then
        path = root.filename
    else
        return nil
    end
    return vim.fn.globpath(path, '**/*.*', false, true)
end

function source:get_completions(ctx, callback)
    if not source._should_show(ctx.bounds.line, ctx.bounds.start_col) then
        callback()
        return
    end

    local files = source._discover_files(require('zola').runtime.shortcode_dir.filename)

    local items = {}

    if files == nil then
        vim.notify('error during file discovery, suggestion unavailable', vim.log.levels.WARN)
        return nil
    end

    for _, file in ipairs(files) do
        local rel_path = vim.fs.relpath(require('zola').runtime.shortcode_dir.filename, file)
        local label = source._label_from_rel_path(rel_path)
        table.insert(items, { label = label, insertText = label .. '()', detail = rel_path, kind = CompletionItemKind.File })
    end

    callback {
        items = items,
    }
end

return source
