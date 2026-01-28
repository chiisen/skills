#!/bin/zsh

# Zsh Fix Script for JoObsidian
# This script diagnoses and fixes common Zsh history and plugin issues.

echo "--- Zsh Diagnostics ---"
echo "Shell: $SHELL"
echo "Histfile: $HISTFILE"

# Fix Symlinks for Homebrew Plugins
fix_plugin_symlink() {
    local plugin_name=$1
    local brew_path=$2
    local target_dir="$HOME/.oh-my-zsh/custom/plugins/$plugin_name"
    
    echo "Processing $plugin_name..."
    
    if [ -d "$brew_path" ]; then
        rm -rf "$target_dir"
        ln -s "$brew_path" "$target_dir"
        
        # Ensure .plugin.zsh suffix exists for OMZ compatibility
        local zsh_file="$target_dir/$plugin_name.zsh"
        local plugin_file="$target_dir/$plugin_name.plugin.zsh"
        
        if [ -f "$zsh_file" ] && [ ! -f "$plugin_file" ]; then
            mv "$zsh_file" "$plugin_file"
            echo "Renamed $plugin_name.zsh to $plugin_name.plugin.zsh"
        fi
        echo "Successfully linked $plugin_name"
    else
        echo "Warning: Brew path $brew_path not found. Skipping."
    fi
}

fix_plugin_symlink "zsh-autosuggestions" "/opt/homebrew/opt/zsh-autosuggestions/share/zsh-autosuggestions"
fix_plugin_symlink "zsh-syntax-highlighting" "/opt/homebrew/opt/zsh-syntax-highlighting/share/zsh-syntax-highlighting"

# History Fix
if [ -f "$HOME/.zsh_history" ]; then
    echo "Repairing .zsh_history..."
    mv "$HOME/.zsh_history" "$HOME/.zsh_history_backup_$(date +%s)"
    strings "$HOME/.zsh_history_backup_*" | tail -n 10000 > "$HOME/.zsh_history"
    echo "History repaired."
fi

echo "--- Fix Complete ---"
echo "Please run 'source ~/.zshrc' to apply changes."
