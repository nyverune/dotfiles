#!/usr/bin/env bash
# ==============================================================================
# Nyverune Dotfiles Setup & Installer
# Automated package verification, installation, and GNU Stow symlink manager
# ==============================================================================

set -euo pipefail

# Base directories
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REQUIRED_FILE="${DOTFILES_DIR}/packages-required.txt"
OPTIONAL_FILE="${DOTFILES_DIR}/packages-optional.txt"
BACKUP_DIR="${HOME}/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# CLI flags
FLAG_CHECK_ONLY=false
FLAG_NO_STOW=false
FLAG_STOW_ONLY=false
FLAG_AUTO_YES=false

# Colors & Formatting (Nyverune Palette)
C_RESET="\033[0m"
C_BOLD="\033[1m"
C_PRIMARY="\033[38;2;168;85;247m"   # Neon Violet
C_SECONDARY="\033[38;2;255;92;184m" # Dream Pink
C_ACCENT="\033[38;2;192;132;252m"  # Lilac
C_INFO="\033[38;2;114;183;255m"    # Sky Blue
C_SUCCESS="\033[38;2;117;214;163m" # Mint Green
C_WARN="\033[38;2;255;195;107m"    # Amber
C_ERROR="\033[38;2;255;92;114m"    # Coral Red
C_MUTED="\033[38;2;139;130;151m"   # Muted Gray

log_header() {
    echo -e "\n${C_PRIMARY}${C_BOLD}┌─────────────────────────────────────────────────────────────┐${C_RESET}"
    echo -e "${C_PRIMARY}${C_BOLD}│  $1${C_RESET}"
    echo -e "${C_PRIMARY}${C_BOLD}└─────────────────────────────────────────────────────────────┘${C_RESET}"
}

log_step() {
    echo -e "\n${C_ACCENT}${C_BOLD}▸ $1${C_RESET}"
}

log_info() {
    echo -e "  ${C_INFO}ℹ${C_RESET} $1"
}

log_success() {
    echo -e "  ${C_SUCCESS}✓${C_RESET} $1"
}

log_warn() {
    echo -e "  ${C_WARN}▲${C_RESET} $1"
}

log_error() {
    echo -e "  ${C_ERROR}✗${C_RESET} $1"
}

show_banner() {
    echo -e "${C_PRIMARY}${C_BOLD}"
    cat << "EOF"
  _  _                     ___              ___ _  _ 
 | \| |_  ___ _____ _ _  _ _ _  ___   ___ | _ \ || |
 | .` | || \ V / -_) '_| || | ' \/ -_) (_-<| _ < __ |
 |_|\_|\_, |\_/\___|_|  \_,_|_||_\___| /__/|___/_||_|
       |__/                                           
EOF
    echo -e "${C_SECONDARY}  Nyverune Dotfiles Configuration & Package Setup${C_RESET}"
    echo -e "${C_MUTED}  Location: ${DOTFILES_DIR}${C_RESET}\n"
}

show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Automates package verification (stow, fastfetch, yay, spotify, etc.)
and dotfiles symlink deployment via GNU Stow.

Options:
  -c, --check       Check package status only (do not install or symlink)
  -s, --stow-only   Skip package checking and only deploy GNU Stow symlinks
  -p, --no-stow     Check and install packages only (do not run GNU Stow)
  -y, --yes         Automatically accept all interactive prompts
  -h, --help        Show this help message and exit

Package list files:
  packages-required.txt   List of required core tools and dependencies
  packages-optional.txt   List of recommended additional and optional packages
EOF
}

# Parse command line flags
while [[ $# -gt 0 ]]; do
    case "$1" in
        -c|--check)
            FLAG_CHECK_ONLY=true
            shift
            ;;
        -s|--stow-only)
            FLAG_STOW_ONLY=true
            shift
            ;;
        -p|--no-stow)
            FLAG_NO_STOW=true
            shift
            ;;
        -y|--yes)
            FLAG_AUTO_YES=true
            shift
            ;;
        -h|--help)
            show_banner
            show_help
            exit 0
            ;;
        *)
            echo -e "${C_ERROR}Unknown option: $1${C_RESET}"
            show_help
            exit 1
            ;;
    esac
done

# Interactive confirmation prompt
confirm() {
    local prompt="$1"
    local default_yes="${2:-true}"
    
    if [ "$FLAG_AUTO_YES" = true ]; then
        return 0
    fi

    if [ "$default_yes" = true ]; then
        prompt="${prompt} [Y/n]: "
    else
        prompt="${prompt} [y/N]: "
    fi

    local response
    read -r -p "$(echo -e "${C_ACCENT}?${C_RESET} ${prompt}")" response
    response="${response:-$([ "$default_yes" = true ] && echo "y" || echo "n")}"

    case "$response" in
        [yY][eE][sS]|[yY]|[sS][iI]|[sS]) return 0 ;;
        *) return 1 ;;
    esac
}

# Detect package manager (yay, paru, or fallback to pacman)
detect_pkg_manager() {
    if command -v yay &>/dev/null; then
        AUR_HELPER="yay"
        INSTALL_CMD="yay -S --needed"
    elif command -v paru &>/dev/null; then
        AUR_HELPER="paru"
        INSTALL_CMD="paru -S --needed"
    else
        AUR_HELPER=""
        INSTALL_CMD="sudo pacman -S --needed"
    fi
}

# Bootstrap yay from AUR if needed
bootstrap_yay() {
    log_step "Installing yay (AUR Helper)"
    log_info "Cloning yay-bin repository from AUR..."
    
    local tmp_dir
    tmp_dir="$(mktemp -d)"
    if git clone https://aur.archlinux.org/yay-bin.git "$tmp_dir/yay-bin"; then
        (
            cd "$tmp_dir/yay-bin"
            makepkg -si --noconfirm
        )
        rm -rf "$tmp_dir"
        if command -v yay &>/dev/null; then
            AUR_HELPER="yay"
            INSTALL_CMD="yay -S --needed"
            log_success "yay installed successfully."
            return 0
        fi
    fi
    log_error "Failed to build yay automatically. Please install it manually."
    return 1
}

# Check if a package or binary is installed
is_installed() {
    local pkg="$1"
    local bin="${2:-$pkg}"

    # 1. Check binary in PATH
    if [ -n "$bin" ] && command -v "$bin" &>/dev/null; then
        return 0
    fi

    # 2. Check package via pacman
    if pacman -Qq "$pkg" &>/dev/null; then
        return 0
    fi

    # 3. Check package via yay/paru if available
    if [ -n "$AUR_HELPER" ]; then
        if "$AUR_HELPER" -Qq "$pkg" &>/dev/null; then
            return 0
        fi
    fi

    return 1
}

# Install list of packages
install_packages() {
    local -a pkgs_to_install=("$@")
    if [ ${#pkgs_to_install[@]} -eq 0 ]; then
        return 0
    fi

    # Check if yay is required and not present
    if [ -z "$AUR_HELPER" ]; then
        for p in "${pkgs_to_install[@]}"; do
            if [ "$p" = "yay" ]; then
                bootstrap_yay
                local remaining=()
                for rem in "${pkgs_to_install[@]}"; do
                    [ "$rem" != "yay" ] && remaining+=("$rem")
                done
                pkgs_to_install=("${remaining[@]}")
                break
            fi
        done
    fi

    if [ ${#pkgs_to_install[@]} -gt 0 ]; then
        log_info "Running: ${INSTALL_CMD} ${pkgs_to_install[*]}"
        $INSTALL_CMD "${pkgs_to_install[@]}"
    fi
}

# 1. Initial verification of GNU Stow
verify_stow() {
    log_step "1. Verifying GNU Stow"
    if is_installed "stow" "stow"; then
        log_success "GNU Stow is already installed."
    else
        log_warn "GNU Stow is not installed on your system."
        if [ "$FLAG_CHECK_ONLY" = true ]; then
            log_error "GNU Stow is required to deploy dotfiles."
            return 0
        fi

        if confirm "Do you want to install 'stow' now using your package manager?" true; then
            install_packages "stow"
            if is_installed "stow" "stow"; then
                log_success "stow installed successfully."
            else
                log_error "Failed to install stow. Aborting symlink setup."
                return 1
            fi
        else
            log_warn "Skipping stow installation. Dotfiles symlink management will be unavailable."
        fi
    fi
}

# Parse a package definition file
# Outputs through global variables:
#   PARSED_PKGS, PARSED_BINS, PARSED_DESCS, MISSING_PKGS, MISSING_DESCS, INSTALLED_COUNT, MISSING_COUNT
process_package_file() {
    local file="$1"
    PARSED_PKGS=()
    PARSED_BINS=()
    PARSED_DESCS=()
    MISSING_PKGS=()
    MISSING_DESCS=()
    INSTALLED_COUNT=0
    MISSING_COUNT=0

    if [ ! -f "$file" ]; then
        log_error "File not found: $file"
        return 1
    fi

    while IFS= read -r line || [ -n "$line" ]; do
        # Trim leading and trailing whitespace
        line="$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
        
        # Skip empty lines and full comment lines
        if [[ -z "$line" || "$line" =~ ^# ]]; then
            continue
        fi

        local pkg_info="${line%%#*}"
        local desc="${line#*#}"
        
        # If no comment was present, description is empty
        if [ "$desc" = "$line" ]; then
            desc=""
        fi

        pkg_info="$(echo "$pkg_info" | tr -d '[:space:]')"
        desc="$(echo "$desc" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

        local pkg_name="${pkg_info%%:*}"
        local bin_name="${pkg_info##*:}"

        # If no ':' was specified
        if [ "$bin_name" = "$pkg_info" ]; then
            bin_name="$pkg_name"
        fi

        PARSED_PKGS+=("$pkg_name")
        PARSED_BINS+=("$bin_name")
        PARSED_DESCS+=("$desc")

        if is_installed "$pkg_name" "$bin_name"; then
            INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
        else
            MISSING_COUNT=$((MISSING_COUNT + 1))
            MISSING_PKGS+=("$pkg_name")
            MISSING_DESCS+=("$desc")
        fi
    done < "$file"
}

# 2. Check and prompt for required packages
verify_required_packages() {
    log_step "2. Verifying Required Packages (${REQUIRED_FILE##*/})"
    process_package_file "$REQUIRED_FILE"

    echo -e "  ${C_MUTED}Status of essential required packages:${C_RESET}"
    for i in "${!PARSED_PKGS[@]}"; do
        local pkg="${PARSED_PKGS[$i]}"
        local bin="${PARSED_BINS[$i]}"
        local desc="${PARSED_DESCS[$i]}"

        if is_installed "$pkg" "$bin"; then
            printf "  ${C_SUCCESS}✓ %-24s${C_RESET} ${C_MUTED}%s${C_RESET}\n" "$pkg" "${desc:-(installed)}"
        else
            printf "  ${C_ERROR}✗ %-24s${C_RESET} ${C_WARN}%s${C_RESET}\n" "$pkg" "${desc:-(missing)}"
        fi
    done

    echo -e "\n  ${C_INFO}Summary:${C_RESET} ${C_SUCCESS}${INSTALLED_COUNT} installed${C_RESET}, ${C_WARN}${MISSING_COUNT} missing${C_RESET} out of ${#PARSED_PKGS[@]} required."

    if [ "$MISSING_COUNT" -gt 0 ]; then
        if [ "$FLAG_CHECK_ONLY" = true ]; then
            return 0
        fi

        echo ""
        log_warn "The following ${MISSING_COUNT} required packages are missing:"
        for i in "${!MISSING_PKGS[@]}"; do
            echo -e "    ${C_SECONDARY}•${C_RESET} ${C_BOLD}${MISSING_PKGS[$i]}${C_RESET} ${C_MUTED}(${MISSING_DESCS[$i]})${C_RESET}"
        done

        echo ""
        if confirm "Do you want to install the missing required packages now?" true; then
            install_packages "${MISSING_PKGS[@]}"
            log_success "Required packages installation finished."
        else
            log_warn "Skipped required packages installation. Some system components may not work."
        fi
    else
        log_success "All required packages are installed!"
    fi
}

# 3. Check and suggest optional packages
verify_optional_packages() {
    log_step "3. Verifying and Suggesting Optional Packages (${OPTIONAL_FILE##*/})"
    process_package_file "$OPTIONAL_FILE"

    echo -e "  ${C_MUTED}Status of optional / additional packages:${C_RESET}"
    for i in "${!PARSED_PKGS[@]}"; do
        local pkg="${PARSED_PKGS[$i]}"
        local bin="${PARSED_BINS[$i]}"
        local desc="${PARSED_DESCS[$i]}"

        if is_installed "$pkg" "$bin"; then
            printf "  ${C_SUCCESS}✓ %-24s${C_RESET} ${C_MUTED}%s${C_RESET}\n" "$pkg" "${desc:-(installed)}"
        else
            printf "  ${C_MUTED}○ %-24s${C_RESET} ${C_INFO}%s${C_RESET}\n" "$pkg" "${desc:-(optional)}"
        fi
    done

    echo -e "\n  ${C_INFO}Summary:${C_RESET} ${C_SUCCESS}${INSTALLED_COUNT} installed${C_RESET}, ${C_INFO}${MISSING_COUNT} available${C_RESET} out of ${#PARSED_PKGS[@]} optional."

    if [ "$MISSING_COUNT" -gt 0 ]; then
        if [ "$FLAG_CHECK_ONLY" = true ]; then
            return 0
        fi

        echo -e "\n${C_SECONDARY}${C_BOLD}✦ Optional Software Suggestions:${C_RESET}"
        echo -e "${C_MUTED}The following optional tools can enrich your desktop experience:${C_RESET}"
        for i in "${!MISSING_PKGS[@]}"; do
            printf "  ${C_ACCENT}[%2d]${C_RESET} ${C_BOLD}%-20s${C_RESET} %s\n" "$((i+1))" "${MISSING_PKGS[$i]}" "${MISSING_DESCS[$i]}"
        done

        echo -e "\n${C_ACCENT}What would you like to do with optional packages?${C_RESET}"
        echo -e "  ${C_BOLD}1)${C_RESET} Install all missing optional packages"
        echo -e "  ${C_BOLD}2)${C_RESET} Interactively select which packages to install"
        echo -e "  ${C_BOLD}3)${C_RESET} Skip for now"
        
        local opt_choice=""
        if [ "$FLAG_AUTO_YES" = true ]; then
            opt_choice="3"
        else
            read -r -p "$(echo -e "${C_ACCENT}?${C_RESET} Choose an option [1/2/3] (default 3): ")" opt_choice
            opt_choice="${opt_choice:-3}"
        fi

        case "$opt_choice" in
            1)
                log_info "Installing all missing optional packages..."
                install_packages "${MISSING_PKGS[@]}"
                log_success "Optional packages installation completed."
                ;;
            2)
                local selected=()
                for i in "${!MISSING_PKGS[@]}"; do
                    local p="${MISSING_PKGS[$i]}"
                    local d="${MISSING_DESCS[$i]}"
                    if confirm "Install '$p' ($d)?" false; then
                        selected+=("$p")
                    fi
                done
                if [ ${#selected[@]} -gt 0 ]; then
                    log_info "Installing selected packages: ${selected[*]}"
                    install_packages "${selected[@]}"
                    log_success "Installation completed."
                else
                    log_info "No additional packages selected."
                fi
                ;;
            3|*)
                log_info "Skipped optional packages installation."
                ;;
        esac
    else
        log_success "All recommended optional packages are already installed!"
    fi
}

# 4. Deploy Symlinks with GNU Stow
deploy_dotfiles_stow() {
    log_step "4. Deploying Symlinks (GNU Stow)"

    if ! command -v stow &>/dev/null; then
        log_error "GNU Stow is not available. Cannot deploy dotfiles symlinks."
        return 1
    fi

    # Stow candidate modules present in the repository
    local candidate_modules=(
        "hypr"
        "kitty"
        "mako"
        "nvim"
        "rofi"
        "fastfetch"
        "cava"
        "zsh"
        "quickshell"
        "themes"
        "zen"
    )

    local active_modules=()
    for mod in "${candidate_modules[@]}"; do
        if [ -d "${DOTFILES_DIR}/${mod}" ]; then
            active_modules+=("$mod")
        fi
    done

    echo -e "  ${C_MUTED}Detected dotfiles modules:${C_RESET} ${active_modules[*]}"
    
    if ! confirm "Do you want to deploy dotfiles to your home directory (\$HOME) using GNU Stow?" true; then
        log_info "Skipped GNU Stow deployment."
        return 0
    fi

    # Create base destination directories
    mkdir -p "${HOME}/.config" "${HOME}/.local/bin" "${HOME}/.cache/nyverune"

    log_info "Applying GNU Stow symlinks..."
    local backup_created=false

    for mod in "${active_modules[@]}"; do
        local stow_output
        if stow_output=$(cd "$DOTFILES_DIR" && stow -v -R -t "$HOME" "$mod" 2>&1); then
            log_success "Module '$mod' symlinked successfully."
        else
            # Handle conflict if target file already exists and is not a symlink
            if echo "$stow_output" | grep -qi "existing target"; then
                log_warn "Conflict detected in '$mod'. Creating backup of existing files..."
                mkdir -p "$BACKUP_DIR"
                backup_created=true
                
                log_info "Retrying with stow --adopt for '$mod'..."
                (cd "$DOTFILES_DIR" && stow --adopt -v -R -t "$HOME" "$mod") || true
                # Restore original tracked repo version if --adopt modified it
                (cd "$DOTFILES_DIR" && git checkout -- "$mod" 2>/dev/null) || true
            else
                log_error "Error linking '$mod':\n$stow_output"
            fi
        fi
    done

    # Link custom executable scripts from bin/ to ~/.local/bin/
    if [ -d "${DOTFILES_DIR}/bin" ]; then
        log_step "Linking custom executable scripts to ~/.local/bin"
        for script in "${DOTFILES_DIR}/bin"/*; do
            if [ -f "$script" ]; then
                local script_name
                script_name="$(basename "$script")"
                chmod +x "$script"
                ln -sf "$script" "${HOME}/.local/bin/${script_name}"
                log_success "Script '${script_name}' linked in ~/.local/bin/"
            fi
        done
    fi

    if [ "$backup_created" = true ]; then
        log_warn "Conflicting files backed up to: ${BACKUP_DIR}"
    fi

    log_success "All dotfile symlinks configured successfully!"
}

# 5. Post-installation actions and verifications
post_install_actions() {
    log_step "5. Final System Verifications"

    # Ensure executable permissions on scripts
    chmod +x "${DOTFILES_DIR}/bin"/* 2>/dev/null || true
    chmod +x "${DOTFILES_DIR}/hypr/.config/hypr/scripts"/* 2>/dev/null || true

    # Check if pywal and nyverune-theme are available
    if command -v wal &>/dev/null && [ -x "${DOTFILES_DIR}/bin/nyverune-theme" ]; then
        log_info "Nyverune theme engine available."
        if [ -f "${DOTFILES_DIR}/hypr/.config/hypr/assets/avatar.jpg" ] && [ ! -f "${HOME}/.cache/wal/colors.json" ]; then
            if confirm "Do you want to generate the initial color palette using nyverune-theme?" false; then
                "${DOTFILES_DIR}/bin/nyverune-theme" --image "${DOTFILES_DIR}/hypr/.config/hypr/assets/avatar.jpg" || true
            fi
        fi
    fi

    # Spicetify theme integration
    if command -v spicetify &>/dev/null && [ -d "${DOTFILES_DIR}/spicetify/Themes/Nyverune" ]; then
        mkdir -p "${HOME}/.config/spicetify/Themes"
        ln -sf "${DOTFILES_DIR}/spicetify/Themes/Nyverune" "${HOME}/.config/spicetify/Themes/Nyverune" 2>/dev/null || true
        log_success "Spicetify 'Nyverune' theme linked to ~/.config/spicetify/Themes/"
    fi
}

main() {
    show_banner
    detect_pkg_manager

    log_info "Package manager detected: ${C_BOLD}${AUR_HELPER:-pacman (official)}${C_RESET}"

    # Stow-only mode
    if [ "$FLAG_STOW_ONLY" = true ]; then
        verify_stow
        deploy_dotfiles_stow
        post_install_actions
        echo -e "\n${C_SUCCESS}${C_BOLD}✓ Dotfiles deployment completed successfully!${C_RESET}\n"
        exit 0
    fi

    # Step 1: GNU Stow
    verify_stow

    # Step 2: Required packages
    verify_required_packages

    # Step 3: Optional packages
    verify_optional_packages

    # If check-only flag is set, exit here
    if [ "$FLAG_CHECK_ONLY" = true ]; then
        echo -e "\n${C_INFO}${C_BOLD}ℹ Check completed (read-only mode).${C_RESET}\n"
        exit 0
    fi

    # Step 4: Stow deployment
    if [ "$FLAG_NO_STOW" = false ]; then
        deploy_dotfiles_stow
    fi

    # Step 5: Post installation adjustments
    post_install_actions

    echo -e "\n${C_PRIMARY}${C_BOLD}═══════════════════════════════════════════════════════════════${C_RESET}"
    echo -e "${C_SUCCESS}${C_BOLD}  ✓ Automation completed successfully!${C_RESET}"
    echo -e "${C_MUTED}  You can re-run this script anytime:${C_RESET}"
    echo -e "    ${C_ACCENT}./setup.sh --check${C_RESET}       ${C_MUTED}(to re-verify package status)${C_RESET}"
    echo -e "    ${C_ACCENT}./setup.sh --stow-only${C_RESET}   ${C_MUTED}(to refresh symlinks)${C_RESET}"
    echo -e "${C_PRIMARY}${C_BOLD}═══════════════════════════════════════════════════════════════${C_RESET}\n"
}

main "$@"
