function set_environment
    set -Ux GTK_IM_MODULE fcitx
    set -Ux QT_IM_MODULE fcitx
    set -Ux XMODIFIERS @im=fcitx
    set -Ux SDL_IM_MODULE fcitx
    # kitty
    set -Ux GLFW_IM_MODULE ibus
	
    set -Ux EDITOR nvim
end

if status is-interactive
    # Commands to run in interactive sessions can go here
end

set_environment
