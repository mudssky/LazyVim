# Validate lazy.nvim availability in headless Neovim
param()

$nv = "nvim"
$cmd1 = "lua local ok,err=pcall(require,'lazy'); if ok then print('lazy ok') else print('lazy missing: '..tostring(err)) end"
$cmd2 = "qa"
& $nv --headless -c $cmd1 -c $cmd2