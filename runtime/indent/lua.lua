-- Nvim indent file
-- Language:        Lua script
-- Maintainer:      NVIM Team
-- First Author:    github.com/gx089
-- Last Change:     2026 Jun 16
--		            2026 Jun 16: gx089: Converted from lua.vim, In favor of active treesitter highlighting, hardcoded commentstring
--
-- Only load this indent file when no other was loaded.

if vim.b.did_indent then
    return
end

vim.b.did_indent = true
vim.bo.indentexpr = "v:lua.GetLuaIndent()"
vim.bo.indentkeys = vim.bo.indentkeys .. ",0=end,0=until"
vim.bo.autoindent = true
vim.b.undo_indent = "setlocal autoindent< indentexpr< indentkeys<"

function GetLuaIndent()
    local ignorecase_save = vim.o.ignorecase
    vim.o.ignorecase = false
    local ok, ret = pcall(GetLuaIndentIntern)
    vim.o.ignorecase = ignorecase_save

    if ok then
        return ret
    else
        return 0
    end
end

function isComment(row)
    local line = vim.fn.getline(row)
    if line:match("^%s*%-%-") then
        return true
    else
        return false
    end
end

function GetLuaIndentIntern()
    local curlnum = vim.v.lnum
    local prevlnum = vim.fn.prevnonblank(curlnum - 1)

    if prevlnum == 0 then
        return 0
    end

    local ind = vim.fn.indent(prevlnum)
    local sw = vim.fn.shiftwidth()
    local curline = vim.fn.getline(curlnum)
    local prevline = vim.fn.getline(prevlnum)

    local match = vim.fn.match

    local midx = match(prevline, [[^\s*\%(if\>\|for\>\|while\>\|repeat\>\|else\>\|elseif\>\|do\>\|then\>\)]])
    if midx == -1 then
        midx = match(prevline, [[\%({\|(\)\s*\%(--\%([^[].*\)\?\)\?$]])
            if midx == -1 then
                midx = match(prevline, [[\<function\>\s*\%(\k\|[.:]\)\{-}\s*(]])
            end
        end

        if midx ~= -1 and not isComment(prevlnum) and (match(prevline, [[\<end\>\|\<until\>]]) == -1) then
        ind = ind + sw
    end

    if not isComment(curlnum) and (match(curline, [[^\s*\%(end\>\|else\>\|elseif\>\|until\>\|}\|)\)]]) ~= -1) then
    ind = ind - sw
end

return ind
end
