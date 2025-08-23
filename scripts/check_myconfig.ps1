# Validate myConfig modules availability in headless Neovim
param()

$nv = "nvim"

$cmd1 = "lua local ok,err=pcall(require,'config.options'); if ok then print('config.options ok') else print('config.options missing: '..tostring(err)) end"
$cmd2 = "lua local ok,err=pcall(require,'config.keymaps'); if ok then print('config.keymaps ok') else print('config.keymaps missing: '..tostring(err)) end"
$cmd3 = "lua local ok,err=pcall(require,'config.autocmds'); if ok then print('config.autocmds ok') else print('config.autocmds missing: '..tostring(err)) end"
$cmd4 = "qa"

& $nv --headless -c $cmd1 -c $cmd2 -c $cmd3 -c $cmd4