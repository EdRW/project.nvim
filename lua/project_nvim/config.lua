local M = {}

---@class ProjectOptions
M.defaults = {
  -- Manual mode doesn't automatically change your root directory, so you have
  -- the option to manually do so using `:ProjectRoot` command.
  manual_mode = false,

  -- Methods of detecting the root directory. **"lsp"** uses the native neovim
  -- lsp, while **"pattern"** uses vim-rooter like glob pattern matching. Here
  -- order matters: if one is not detected, the other is used as fallback. You
  -- can also delete or rearangne the detection methods.
  detection_methods = { "lsp", "pattern" },

  -- All the patterns used to detect root dir, when **"pattern"** is in
  -- detection_methods
  patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json" },

  -- Table of lsp clients to ignore by name
  -- eg: { "efm", ... }
  ignore_lsp = {},

  -- Don't calculate root dir on specific directories
  -- Ex: { "~/.cargo/*", ... }
  exclude_dirs = {},

  -- Show hidden files in telescope
  show_hidden = false,

  -- When set to false, you will get a message when project.nvim changes your
  -- directory.
  silent_chdir = true,

  -- Path where project.nvim will store the project history for use in
  -- telescope
  datapath = vim.fn.stdpath("data"),

  -- Function to call when you select a project from telecope
  -- Accepts:
  --    "find_project_files"        : call 'Telescope find_files' on project
  --    "browse_project_files"      : call 'Telescope file_browser' on project
  --    "search_in_project_files"   : call 'Telescope live_grep' on project
  --    "recent_project_files"      : call 'Telescope oldfiles' on project
  --    "change_working_directory"  : just change the directory
  -- Note: All will change the directory regardless
  telescope_on_project_selected = "find_project_files"
}

---@type ProjectOptions
M.options = {}

M.setup = function(options)
  M.options = vim.tbl_deep_extend("force", M.defaults, options or {})

  local glob = require("project_nvim.utils.globtopattern")
  local home = vim.fn.expand("~")
  M.options.exclude_dirs = vim.tbl_map(function(pattern)
    if vim.startswith(pattern, "~/") then
      pattern = home .. "/" .. pattern:sub(3, #pattern)
    end
    return glob.globtopattern(pattern)
  end, M.options.exclude_dirs)

  vim.opt.autochdir = false -- implicitly unset autochdir

  require("project_nvim.utils.path").init()
  require("project_nvim.project").init()
end

return M
