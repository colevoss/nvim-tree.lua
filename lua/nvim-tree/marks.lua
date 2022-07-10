local view = require "nvim-tree.view"
local Iterator = require "nvim-tree.iterators.node-iterator"
local core = require "nvim-tree.core"

_G.NvimTreeMarks = {}

local M = {}

function M.add_mark(node)
  _G.NvimTreeMarks[node.absolute_path] = true
  M.draw()
end

function M.get_mark(node)
  return _G.NvimTreeMarks[node.absolute_path]
end

function M.remove_mark(node)
  _G.NvimTreeMarks[node.absolute_path] = nil
  M.draw()
end

function M.toggle_mark(node)
  if M.get_mark(node) then
    M.remove_mark(node)
  else
    M.add_mark(node)
  end
end

function M.get_marks()
  local list = {}
  for k in pairs(_G.NvimTreeMarks) do
    table.insert(list, k)
  end
  return list
end

local GROUP = "NvimTreeMarkSigns"
local SIGN_NAME = "NvimTreeMark"

function M.clear()
  vim.fn.sign_unplace(GROUP)
end

function M.draw()
  if not view.is_visible() then
    return
  end

  M.clear()

  local buf = view.get_bufnr()
  Iterator.builder(core.get_explorer().nodes)
    :recursor(function(node)
      return node.open and node.nodes
    end)
    :applier(function(node, idx)
      if M.get_mark(node) then
        vim.fn.sign_place(0, GROUP, SIGN_NAME, buf, { lnum = idx + 1, priority = 3 })
      end
    end)
    :iterate()
end

function M.setup(opts)
  vim.fn.sign_define(SIGN_NAME, { text = opts.renderer.icons.glyphs.bookmark, texthl = "NvimTreeBookmark" })
end

return M
