#
# ~/.bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return


#alias 
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias :q="exit"
alias :wq="exit"
alias cdir='cd "${_%/*}"'
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    alias record='wf-recorder -f "$HOME/Videos/screen_record_$(date +%Y-%m-%d_%H-%M-%S).mp4"'
elif [ "$XDG_SESSION_TYPE" = "x11" ]; then
    alias record='ffmpeg -f x11grab -framerate 60 -i :0.0 -c:v h264_nvenc -profile:v high "$HOME/Videos/screen_record_$(date +%Y-%m-%d_%H-%M-%S).mp4"'
fi
alias batstat='upower -i $(upower -e | grep bat)'



# ps1
PS1='\e[34m[\e[35m\u\e[34m@\e[35m\h\e[36m \W\e[34m]\$ \e[0m'



# devkitarm
export DEVKITPRO=/opt/devkitpro
export DEVKITARM=/opt/devkitpro/devkitARM
export DEVKITPPC=/opt/devkitpro/devkitPPC


#path
export PATH="$HOME/.local/share/gem/ruby/3.3.0/bin:$HOME/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH=$PATH:$DEVKITARM/bin

#cuda
export PATH="/opt/cuda/bin:$PATH"
export LD_LIBRARY_PATH="/opt/cuda/lib64:$LD_LIBRARY_PATH"

#ble.sh
source ~/.local/share/blesh/ble.sh

# randomass
export NVCC_CCBIN=/usr/bin/g++
export QT_QPA_PLATFORMTHEME=qt5ct
export ELECTRON_TRASH=trash-cli
export GTK_THEME=Rosepine-Dark
