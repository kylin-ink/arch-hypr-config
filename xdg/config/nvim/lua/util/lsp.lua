local M = {}
function M.set_keymap(bufnr, mode, lhs, rhs, opts)
  opts = M.make_opts(opts)
  vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
end

M.opts = { noremap = true, silent = true }

function M.make_opts(opts)
  return vim.tbl_extend("keep", opts, M.opts)
end

function M.setup(client, bufnr)
  if client.server_capabilities.documentHighlightProvider then
    vim.api.nvim_create_augroup("lsp_document_highlight", {
      clear = false,
    })
    vim.api.nvim_clear_autocmds({
      buffer = bufnr,
      group = "lsp_document_highlight",
    })
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      group = "lsp_document_highlight",
      buffer = bufnr,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
      group = "lsp_document_highlight",
      buffer = bufnr,
      callback = vim.lsp.buf.clear_references,
    })
  end
  -- inlay hint
  if client.supports_method("textDocument/inlayHint", { bufnr = bufnr }) then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end
  -- code lens
  if client.supports_method("textDocument/codeLens", { bufnr = bufnr }) then
    vim.lsp.codelens.refresh({ bufnr = bufnr })
    vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave" }, {
      buffer = bufnr,
      callback = function()
        vim.lsp.codelens.refresh({ bufnr = bufnr })
      end,
    })
  end
  M.setup_buf_map(bufnr)
  M.setup_cwd(bufnr)
end

function M.make_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
  return capabilities
end

function M.get_mason_pkg_path()
  local mason_path = os.getenv("MASON")
  if mason_path ~= nil then
    return mason_path .. "/packages"
  end
  return vim.fn.stdpath("data") .. "/mason/packages"
end

function M.setup_buf_map(bufnr)
  local map = M.set_keymap
  map(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", { desc = "Lsp Hover" })
  map(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", { desc = "Lsp Declaration" })
  map(
    bufnr,
    "n",
    "gd",
    "<cmd>Telescope lsp_definitions reuse_win=true<CR>",
    { desc = "Telescope Lsp Definitions" }
  )
  map(
    bufnr,
    "n",
    "gt",
    "<cmd>Telescope lsp_type_definitions reuse_win=true<CR>",
    { desc = "Telescope Lsp Definitions" }
  )
  map(
    bufnr,
    "n",
    "gi",
    "<cmd>Telescope lsp_implementations reuse_win=true<CR>",
    { desc = "Telescope Lsp Implementations" }
  )
  map(
    bufnr,
    "n",
    "gI",
    "<cmd>Telescope lsp_incoming_calls<CR>",
    { desc = "Telescope Lsp Incoming Calls" }
  )
  map(
    bufnr,
    "n",
    "gR",
    "<cmd>Telescope lsp_outgoing_calls<CR>",
    { desc = "Telescope Lsp_outgoing Calls" }
  )
  map(
    bufnr,
    "n",
    "gr",
    "<cmd>Telescope lsp_references show_line=false include_declaration=false<CR>",
    { desc = "Telescope Lsp References" }
  )
end

function M.detect_root(bufnr)
  local buf_ft = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  if next(clients) == nil then
    return nil
  end

  for _, client in pairs(clients) do
    ---@diagnostic disable-next-line: undefined-field
    local filetypes = client.config.filetypes
    if filetypes and vim.tbl_contains(filetypes, buf_ft) then
      -- return first match root and lsp client name
      return client.config.root_dir, client.name
    end
  end
end

function M.setup_cwd(bufnr)
  local cwd = vim.fn.getcwd()
  local root, client_name = M.detect_root(bufnr)
  if root and root ~= cwd then
    M.chdir(root)
    vim.notify("Set CWD to " .. root .. " using " .. client_name)
    return
  end
  root = vim.fs.root(bufnr, { ".git", ".svn", "Makefile", "mvnw", "package.json" })
  if root and root ~= "." and root ~= cwd then
    M.chdir(root)
    vim.notify("Set CWD to " .. root)
  end
end

function M.chdir(path)
  ---@diagnostic disable-next-line: undefined-field
  vim.uv.chdir(path)
end

return M
