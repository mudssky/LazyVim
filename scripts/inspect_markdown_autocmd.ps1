# Inspect markdown FileType autocmds and mappings in headless Neovim (enhanced)
param()

$nv = "nvim"
$cmds = @(
  # wait a bit for scheduled callbacks
  "lua vim.wait(300)",
  # Print stdpath('config') to confirm which init.lua is used
  "lua print('stdpath(config)=', vim.fn.stdpath('config'))",
  # Show entire rtp and whether myConfig is included
  "lua print('rtp has myConfig path:', vim.o.rtp)",
  "lua print('rtp contains /myConfig:', string.find(vim.o.rtp, '/myConfig') ~= nil)",
  # Ensure our autocmds module is required (in case scheduled load hasn't run yet)
  "lua local ok,err=pcall(require,'config.autocmds'); print('require config.autocmds:', ok, ok and '' or err)",
  # List FileType autocmds for markdown
  "verbose autocmd FileType markdown",
  # Open a scratch buffer, set filetype via :setfiletype, then trigger FileType autocmds
  "lua vim.cmd('enew') vim.cmd('setfiletype markdown')",
  "doautocmd FileType markdown",
  # Show mappings for <C-1>.. <C-6> in normal & insert mode (verbose)
  "lua for i=1,6 do print('check nmap <C-'..i..'>:'); vim.cmd('silent verbose nmap <C-'..i..'>') end",
  "lua for i=1,6 do print('check imap <C-'..i..'>:'); vim.cmd('silent verbose imap <C-'..i..'>') end",
  "qa"
)

& $nv --headless -c $cmds[0] -c $cmds[1] -c $cmds[2] -c $cmds[3] -c $cmds[4] -c $cmds[5] -c $cmds[6] -c $cmds[7] -c $cmds[8] -c $cmds[9] -c $cmds[10]