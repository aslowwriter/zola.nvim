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
    return vim.bo.filetype == 'markdown' and M.runtime.content_dir ~= nil
end

function source:get_trigger_characters()
    return { '@' }
end

function source._label_from_rel_path(path)
    -- just to be sure
    if path == nil then
        return nil
    end

    if path == '_index.md' or path == '/' or path == '.' then
        return 'root'
    end

    local label = path
    label = string.gsub(label, '%.md$', '')
    label = string.gsub(label, '/index$', '')
    label = string.gsub(label, '/_index$', '')

    return label
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

function source._filter_ignored_content(files, ignore_globs) end

function source:get_completions(_ctx, callback)
    local files = source._discover_files(M.runtime.content_dir.filename)

    local items = {}

    if files == nil then
        vim.notify('error during file discovery, suggestion unavailable', vim.log.levels.WARN)
        return items
    end

    for _, file in ipairs(files) do
        local rel_path = vim.fs.relpath(M.runtime.content_dir.filename, file)
        local label = source._label_from_rel_path(rel_path)
        table.insert(items, { label = label, insertText = '/' .. rel_path, detail = rel_path, kind = CompletionItemKind.File })
    end

    callback {
        items = items,
    }
end

return source
