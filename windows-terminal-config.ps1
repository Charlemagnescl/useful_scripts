# code reference
# [1]: https://www.raimis.me/archives/80/

# set the port of your system proxy
$port_proxy=7890

# config the proxy of your git
git config --global http.proxy ("'socks5://127.0.0.1:" + $port_proxy + "'")
git config --global https.proxy ("'socks5://127.0.0.1:" + $port_proxy + "'")

# install package management tool scoop
Set-ExecutionPolicy RemoteSigned -scope CurrentUser
Invoke-WebRequest -useb get.scoop.sh | Invoke-Expression

# install oh-my-posh
scoop install https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/oh-my-posh.json

# install Meslo NF font
scoop bucket add nerd-fonts
scoop install nerd-fonts/Meslo-NF

# Some other settings to be done mannually
Write-Output "\033[0;32m [+] The Meslo-NF font is successfully install, but you still need to config it in the setting page of your windows terminal"

# install Terminal-Icons
scoop bucket add extras
scoop install terminal-icons

# install posh-git
scoop bucket add extras
scoop install posh-git

# config your powershell
Write-Output "oh-my-posh init pwsh --config ~\scoop\apps\oh-my-posh\current\themes\material.omp.json | Invoke-Expression" >> $PROFILE
Write-Output "Import-Module -Name Terminal-Icons" >> $PROFILE
Write-Output "Import-Module posh-git" >> $PROFILE