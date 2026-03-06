#!/bin/bash
#
# Reality Redemption BETA 3.0 PC Installer - Linux shell script
# Converted from RR Beta 3.0 PC Installer.bat
# Run from the Reality Redemption folder (same folder as RDR.exe's parent)
#
# Wine troubleshooting (kernel32.dll / c0000135 errors):
#   1. Regenerate prefix:    rm -rf ~/.wine
#   2. Install 32-bit Wine:  Ubuntu/Debian: sudo apt install wine32
#                           Fedora: sudo dnf install wine
#                           Arch: sudo pacman -S wine
#                           openSUSE: sudo zypper install wine
#   3. Use dedicated prefix: WINEPREFIX=~/.wine-rr WINEARCH=win32 ./"RR Beta 3.0 PC Installer.sh"
#
# Wine Mono (.NET): MagicRDR.exe needs .NET. If you see "Wine Mono is not installed",
#   run: winetricks dotnet48  (after installing winetricks for your distro)
#

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GAME_DIR="$(dirname "$SCRIPT_DIR")"

show_help() {
    echo "Reality Redemption BETA 3.0 PC Installer"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help    Show this help and Wine troubleshooting steps"
    echo ""
    echo "Wine troubleshooting (if you get kernel32.dll or c0000135 errors):"
    echo "  1. Regenerate Wine prefix:  rm -rf ~/.wine"
    echo "  2. Install Wine + winetricks:"
    echo "     Ubuntu/Debian:  sudo apt install wine wine32 winetricks"
    echo "     Fedora:        sudo dnf install wine winetricks"
    echo "     Arch:          sudo pacman -S wine winetricks"
    echo "     openSUSE:      sudo zypper install wine winetricks"
    echo "  3. Use a dedicated prefix: WINEPREFIX=~/.wine-rr WINEARCH=win32 $0"
    echo ""
    echo "Wine Mono (.NET) errors: If you see \"Wine Mono is not installed\":"
    echo "  Install winetricks (see above), then:"
    echo "  WINEPREFIX=~/.wine-rr WINEARCH=win32 winetricks dotnet48"
    echo "  (Use WINEPREFIX/WINEARCH if you use a custom prefix)"
    echo ""
    exit 0
}

[[ "$1" == "-h" || "$1" == "--help" ]] && show_help

# MagicRDR.exe must run via Wine - it modifies RPF archives
# Wine inherits WINEPREFIX and WINEARCH from environment if set
run_magicrdr() {
    cd "$SCRIPT_DIR" || exit
    if ! command -v wine &>/dev/null; then
        echo "Wine is not installed. Install it for your distro (e.g. apt/dnf/pacman/zypper). Run $0 --help for commands."
        exit 1
    fi
    local output
    output=$(wine ./MagicRDR.exe "$@" 2>&1)
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        echo "MagicRDR failed. Check that MagicRDR.exe exists and Wine is configured correctly."
        if [[ -n "$output" ]]; then
            echo ""
            echo "Error output:"
            echo "$output"
        fi
        if [[ "$output" == *"kernel32.dll"* ]]; then
            echo ""
            echo "Troubleshooting: This often means Wine 32-bit support is missing or the Wine prefix is corrupted."
            echo "Try: 1) rm -rf ~/.wine  2) Install wine32/wine for your distro (see --help)  3) Run this script again."
            echo "Or run with: WINEPREFIX=~/.wine-rr WINEARCH=win32 $0"
        fi
        if [[ "$output" == *"Wine Mono"* || "$output" == *"mscoree"* ]]; then
            echo ""
            echo "Troubleshooting: MagicRDR.exe needs Wine Mono (.NET runtime) to run."
            echo "  1. Install winetricks for your distro (apt/dnf/pacman/zypper; see --help)"
            echo "  2. Install .NET Framework:  winetricks dotnet48"
            echo "     (If using a custom prefix, run: WINEPREFIX=~/.wine-rr WINEARCH=win32 winetricks dotnet48)"
            echo "  3. Run this script again."
        fi
        exit 1
    fi
}

yesno_prompt() {
    local prompt="$1"
    read -r -p "$prompt" yesno
    yesno=$(echo "$yesno" | tr '[:upper:]' '[:lower:]')
    [[ "$yesno" = "y" ]]
}

pause_key() {
    read -n 1 -s -r -p "Press any key to continue..."
    echo
}

missing_files() {
    clear
    echo "Required game files cannot be found, make sure you've placed the Reality Redemption folder where RDR.exe is"
    echo ""
    echo ""
    echo "Put the Reality Redemption FOLDER in the RDR installation folder, then enter Reality Redemption folder and run the .sh script from there"
    echo ""
    echo ""
    pause_key
    exit 1
}

missing_uninstall_files() {
    clear
    echo "Required files in the update folder cannot be found, are you sure you haven't manually uninstalled the mod?"
    echo ""
    echo ""
    echo ""
    pause_key
    exit 1
}

# Create RR-Temp directory structure for uninstall
create_rr_temp_dirs() {
    cd "$SCRIPT_DIR" || exit
    mkdir -p RR-Temp/mapres RR-Temp/mapres_loadingscreens RR-Temp/mapres_minimap
    mkdir -p RR-Temp/mapres_terrain RR-Temp/mapres_smics RR-Temp/fragments_vegetation
    mkdir -p RR-Temp/territory_swall/armadillo/armadillo
    mkdir -p RR-Temp/territory_swall/beechershope/beechershope
    mkdir -p RR-Temp/territory_swall/beechershope/beh_house01x
    mkdir -p RR-Temp/territory_swall/blackwater/blackwater
    mkdir -p RR-Temp/territory_swall/chuparosa/chuparosa
    mkdir -p RR-Temp/territory_swall/escalara/escalara
    mkdir -p RR-Temp/territory_swall/fortmercer/fortmercer
    mkdir -p RR-Temp/territory_swall/hennigansranch/hen_barn01props01x
    mkdir -p RR-Temp/territory_swall/hennigansranch/hen_barn01x
    mkdir -p RR-Temp/territory_swall/hennigansranch/hen_barn02props01x
    mkdir -p RR-Temp/territory_swall/hennigansranch/hen_barn02x
    mkdir -p RR-Temp/territory_swall/hennigansranch/hen_blacksmith01props01x
    mkdir -p RR-Temp/territory_swall/hennigansranch/hen_blacksmith01x
    mkdir -p RR-Temp/territory_swall/hennigansranch/hen_bridge01x
    mkdir -p RR-Temp/territory_swall/hennigansranch/hen_bunkhouse01props01x
    mkdir -p RR-Temp/territory_swall/hennigansranch/hen_bunkhouse01x
    mkdir -p RR-Temp/territory_swall/hennigansranch/hen_bunkhouse02x
    mkdir -p RR-Temp/territory_swall/hennigansranch/hen_cottage01props01x
    mkdir -p RR-Temp/territory_swall/hennigansranch/hen_cottage01x
    mkdir -p RR-Temp/territory_swall/hennigansranch/hen_cottage02props01x
    mkdir -p RR-Temp/territory_swall/hennigansranch/hen_cottage02x
    mkdir -p RR-Temp/territory_swall/hennigansranch/hen_cottage03props01x
    mkdir -p RR-Temp/territory_swall/hennigansranch/hen_cottage03x
    mkdir -p RR-Temp/territory_swall/hennigansranch/hen_entrancefence01x
    mkdir -p RR-Temp/territory_swall/hennigansranch/hen_flags01x
    mkdir -p RR-Temp/territory_swall/hennigansranch/hen_garden01x
    mkdir -p RR-Temp/territory_swall/hennigansranch/hen_henniganshouse01props01x
    mkdir -p RR-Temp/territory_swall/hennigansranch/hen_henniganshouse01props02x
    mkdir -p RR-Temp/territory_swall/hennigansranch/hen_henniganshouse01x
    mkdir -p RR-Temp/territory_swall/hennigansranch/hen_outhouse01x
    mkdir -p RR-Temp/territory_swall/hennigansranch/hen_shootinggallery01x
    mkdir -p RR-Temp/territory_swall/hennigansranch/hen_shootinggalleryprops01x
    mkdir -p RR-Temp/territory_swall/hennigansranch/hen_stable01b
    mkdir -p RR-Temp/territory_swall/hennigansranch/hen_stable01props01x
    mkdir -p RR-Temp/territory_swall/hennigansranch/hen_stable01x
    mkdir -p RR-Temp/territory_swall/hennigansranch/hen_stable02props01x
    mkdir -p RR-Temp/territory_swall/hennigansranch/hen_stable02x
    mkdir -p RR-Temp/territory_swall/hennigansranch/hen_stable03props01x
    mkdir -p RR-Temp/territory_swall/hennigansranch/hen_stable03x
    mkdir -p RR-Temp/territory_swall/hennigansranch/hen_stockade01props01x
    mkdir -p RR-Temp/territory_swall/hennigansranch/hen_stockade01x
    mkdir -p RR-Temp/territory_swall/hennigansranch/hen_store01props01x
    mkdir -p RR-Temp/territory_swall/hennigansranch/hen_store01x
    mkdir -p RR-Temp/territory_swall/hennigansranch/hen_trainstation01props01x
    mkdir -p RR-Temp/territory_swall/hennigansranch/hen_trainstation01x
    mkdir -p RR-Temp/territory_swall/hennigansranch/hen_watertower01x
    mkdir -p RR-Temp/territory_swall/hennigansranch/hennigansranch
    mkdir -p RR-Temp/mapres_player RR-Temp/fragments RR-Temp/grassres RR-Temp/naturalmotion
    mkdir -p RR-Temp/content/ai RR-Temp/camera RR-Temp/tune_skycycle/skyhat RR-Temp/tune_ppp
    mkdir -p RR-Temp/fragments_clouds RR-Temp/mapres_rr RR-Temp/content/ambient
    mkdir -p RR-Temp/tune/debris RR-Temp/tune/fire RR-Temp/tune/materials RR-Temp/tune/physics RR-Temp/tune/trees
}

# ============================================================================
# MAIN MENU
# ============================================================================
main_menu() {
    clear
    echo "Welcome to the Reality Redemption BETA 3.0 automatic installation for PC!"
    echo "Read the ReadMe file to avoid any errors while installing the mod!"
    echo ""
    echo ""
    echo ""
    pause_key
    clear
    echo "[1] Install Reality Redemption"
    echo "[2] Uninstall Reality Redemption"
    echo "[3] Cancel and Exit"
    echo ""
    echo ""
    read -r -n 1 -p "It's time to choose: " choice
    echo
    case "$choice" in
        1) install_reality_redemption ;;
        2) uninstall_reality_redemption ;;
        3) echo ""; echo "I had a god damn PLAN! Press any key to exit..."; pause_key; exit 0 ;;
        *) main_menu ;;
    esac
}

# ============================================================================
# INSTALL FLOW
# ============================================================================
install_reality_redemption() {
    echo ""
    echo ""
    echo "Checking to see if the installer can find the game files..."
    sleep 2
    echo ""

    # Check required game files exist
    local required_files=(
        "$GAME_DIR/game/camera.rpf"
        "$GAME_DIR/game/content.rpf"
        "$GAME_DIR/game/fragments.rpf"
        "$GAME_DIR/game/grassres.rpf"
        "$GAME_DIR/game/mapres.rpf"
        "$GAME_DIR/game/naturalmotion.rpf"
        "$GAME_DIR/game/navres.rpf"
        "$GAME_DIR/game/tune_d11generic.rpf"
    )
    for f in "${required_files[@]}"; do
        if [[ ! -f "$f" ]]; then
            missing_files
        fi
    done

    echo "Installing Ultimate ASI Loader and copying the necessary game files into the update folder, might take a while..."
    cd "$SCRIPT_DIR" || exit
    [[ -f "RR-Files/USL/dinput8.dll" ]] && cp -f "RR-Files/USL/dinput8.dll" "$GAME_DIR/" 2>/dev/null || true
    mkdir -p "$GAME_DIR/plugins"
    mkdir -p "$GAME_DIR/update/game"
    mkdir -p "$GAME_DIR/update/game/redemption/territory_swall"

    # Copy RPF files to update folder if not present
    local rpf_copies=(
        "game/redemption/territory_swall/armadillo.rpf"
        "game/redemption/territory_swall/beechershope.rpf"
        "game/redemption/territory_swall/blackwater.rpf"
        "game/redemption/territory_swall/chuparosa.rpf"
        "game/redemption/territory_swall/escalara.rpf"
        "game/redemption/territory_swall/fortmercer.rpf"
        "game/redemption/territory_swall/hennigansranch.rpf"
        "game/camera.rpf"
        "game/content.rpf"
        "game/fragments.rpf"
        "game/grassres.rpf"
        "game/mapres.rpf"
        "game/naturalmotion.rpf"
        "game/navres.rpf"
        "game/tune_d11generic.rpf"
        "game/vfx.rpf"
    )
    for rpf in "${rpf_copies[@]}"; do
        src="$GAME_DIR/$rpf"
        dst="$GAME_DIR/update/$rpf"
        if [[ -f "$src" && ! -f "$dst" ]]; then
            cp -f "$src" "$dst" 2>/dev/null || true
        fi
    done

    echo ""
    echo ""
    sleep 2
    echo "Prepared all of the necessary files! proceeding with the installation as planned..."
    sleep 2
    clear

    echo "[1] Install Automatically (Install every mod feature)"
    echo "[2] Install Manually (Handpick features)"
    echo "[3] Cancel and Exit"
    echo ""
    echo ""
    read -r -n 1 -p "It's time to choose: " choice
    echo
    case "$choice" in
        1) install_automatic ;;
        2) install_manual ;;
        3) echo ""; echo "I had a god damn PLAN! Press any key to exit..."; pause_key; exit 0 ;;
        *) install_reality_redemption ;;
    esac
}

install_manual() {
    echo ""
    echo "The installer will now ask you which features of the mod you would like to install..."
    echo ""
    echo ""
    sleep 2

    cd "$SCRIPT_DIR" || exit

    if yesno_prompt "Install Fusion Mod? (Skip intro) [Y/N]: "; then
        cp -f "RR-Files/plugins/RedDeadRedemption.FusionMod.asi" "$GAME_DIR/plugins/" 2>/dev/null || true
        cp -f "RR-Files/plugins/RedDeadRedemption.FusionMod.ini" "$GAME_DIR/plugins/" 2>/dev/null || true
        echo "Installed Fusion Mod."
    else
        echo "Skipping Fusion Mod..."
    fi

    if yesno_prompt "Install HD loading screens? [Y/N]: "; then
        run_magicrdr -replace "../update/game/mapres.rpf" root/mapres "RR-Files/mapres_loadingscreens" -current
    else
        echo "Skipping HD loading screens..."
    fi

    if yesno_prompt "Install HD lore-accurate minimap? [Y/N]: "; then
        run_magicrdr -replace "../update/game/mapres.rpf" root/mapres "RR-Files/mapres_minimap" -current
    else
        echo "Skipping HD lore-accurate minimap..."
    fi

    if yesno_prompt "Install HD game world textures? (ground, roads, trails, trees, cliffs, buildings, props, etc..) [Y/N]: "; then
        run_magicrdr -replace "../update/game/mapres.rpf" root/mapres "RR-Files/mapres_terrain" -current
        run_magicrdr -replace "../update/game/mapres.rpf" root/mapres "RR-Files/mapres_smics" -current
        run_magicrdr -replace "../update/game/fragments.rpf" root/fragments "RR-Files/fragments_vegetation" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/armadillo.rpf" root/armadillo/armadillo "RR-Files/territory_swall/armadillo/armadillo" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/beechershope.rpf" root/beechershope/beechershope "RR-Files/territory_swall/beechershope/beechershope" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/beechershope.rpf" root/beechershope/beh_house01x "RR-Files/territory_swall/beechershope/beh_house01x" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/blackwater.rpf" root/blackwater/blackwater "RR-Files/territory_swall/blackwater/blackwater" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/chuparosa.rpf" root/chuparosa/chuparosa "RR-Files/territory_swall/chuparosa/chuparosa" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/escalara.rpf" root/escalara/escalara "RR-Files/territory_swall/escalara/escalara" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/fortmercer.rpf" root/fortmercer/fortmercer "RR-Files/territory_swall/fortmercer/fortmercer" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_barn01props01x "RR-Files/territory_swall/hennigansranch/hen_barn01props01x" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_barn01x "RR-Files/territory_swall/hennigansranch/hen_barn01x" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_barn02props01x "RR-Files/territory_swall/hennigansranch/hen_barn02props01x" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_barn02x "RR-Files/territory_swall/hennigansranch/hen_barn02x" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_blacksmith01props01x "RR-Files/territory_swall/hennigansranch/hen_blacksmith01props01x" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_blacksmith01x "RR-Files/territory_swall/hennigansranch/hen_blacksmith01x" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_bridge01x "RR-Files/territory_swall/hennigansranch/hen_bridge01x" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_bunkhouse01props01x "RR-Files/territory_swall/hennigansranch/hen_bunkhouse01props01x" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_bunkhouse01x "RR-Files/territory_swall/hennigansranch/hen_bunkhouse01x" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_bunkhouse02x "RR-Files/territory_swall/hennigansranch/hen_bunkhouse02x" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_cottage01props01x "RR-Files/territory_swall/hennigansranch/hen_cottage01props01x" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_cottage01x "RR-Files/territory_swall/hennigansranch/hen_cottage01x" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_cottage02props01x "RR-Files/territory_swall/hennigansranch/hen_cottage02props01x" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_cottage02x "RR-Files/territory_swall/hennigansranch/hen_cottage02x" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_cottage03props01x "RR-Files/territory_swall/hennigansranch/hen_cottage03props01x" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_cottage03x "RR-Files/territory_swall/hennigansranch/hen_cottage03x" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_entrancefence01x "RR-Files/territory_swall/hennigansranch/hen_entrancefence01x" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_flags01x "RR-Files/territory_swall/hennigansranch/hen_flags01x" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_garden01x "RR-Files/territory_swall/hennigansranch/hen_garden01x" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_henniganshouse01props01x "RR-Files/territory_swall/hennigansranch/hen_henniganshouse01props01x" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_henniganshouse01props02x "RR-Files/territory_swall/hennigansranch/hen_henniganshouse01props02x" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_henniganshouse01x "RR-Files/territory_swall/hennigansranch/hen_henniganshouse01x" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_outhouse01x "RR-Files/territory_swall/hennigansranch/hen_outhouse01x" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_shootinggallery01x "RR-Files/territory_swall/hennigansranch/hen_shootinggallery01x" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_shootinggalleryprops01x "RR-Files/territory_swall/hennigansranch/hen_shootinggalleryprops01x" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_stable01b "RR-Files/territory_swall/hennigansranch/hen_stable01b" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_stable01props01x "RR-Files/territory_swall/hennigansranch/hen_stable01props01x" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_stable01x "RR-Files/territory_swall/hennigansranch/hen_stable01x" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_stable02props01x "RR-Files/territory_swall/hennigansranch/hen_stable02props01x" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_stable02x "RR-Files/territory_swall/hennigansranch/hen_stable02x" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_stable03props01x "RR-Files/territory_swall/hennigansranch/hen_stable03props01x" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_stable03x "RR-Files/territory_swall/hennigansranch/hen_stable03x" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_stockade01props01x "RR-Files/territory_swall/hennigansranch/hen_stockade01props01x" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_stockade01x "RR-Files/territory_swall/hennigansranch/hen_stockade01x" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_store01props01x "RR-Files/territory_swall/hennigansranch/hen_store01props01x" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_store01x "RR-Files/territory_swall/hennigansranch/hen_store01x" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_trainstation01props01x "RR-Files/territory_swall/hennigansranch/hen_trainstation01props01x" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_trainstation01x "RR-Files/territory_swall/hennigansranch/hen_trainstation01x" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_watertower01x "RR-Files/territory_swall/hennigansranch/hen_watertower01x" -current
        run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hennigansranch "RR-Files/territory_swall/hennigansranch/hennigansranch" -current
    else
        echo "Skipping HD game world textures..."
    fi

    if yesno_prompt "Install HD John Marston textures? [Y/N]: "; then
        run_magicrdr -replace "../update/game/mapres.rpf" root/mapres "RR-Files/mapres_player" -current
    else
        echo "Skipping HD John Marston textures..."
    fi

    if yesno_prompt "Install HD secondary characters and generic ped textures? [Y/N]: "; then
        run_magicrdr -replace "../update/game/fragments.rpf" root/fragments "RR-Files/fragments" -current
    else
        echo "Skipping HD secondary characters and generic ped textures..."
    fi

    if yesno_prompt "Install HD RDR2-styled grass textures? [Y/N]: "; then
        run_magicrdr -replace "../update/game/grassres.rpf" root/grassres "RR-Files/grassres" -current
    else
        echo "Skipping HD grass textures..."
    fi

    if yesno_prompt "Install Enhanced Euphoria ragdoll behaviours? [Y/N]: "; then
        run_magicrdr -replace "../update/game/naturalmotion.rpf" root/naturalmotion "RR-Files/naturalmotion" -current
        run_magicrdr -replace "../update/game/content.rpf" root/content/ai "RR-Files/content/ai" -current
    else
        echo "Skipping enhanced ragdoll behaviours..."
    fi

    if yesno_prompt "Install RDR2-styled Camera? [Y/N]: "; then
        run_magicrdr -replace "../update/game/camera.rpf" root/camera "RR-Files/camera" -current
    else
        echo "Skipping RDR2-styled Camera..."
    fi

    if yesno_prompt "Install RDR2-styled timecycle, color scheme and weathers? [Y/N]: "; then
        run_magicrdr -replace "../update/game/tune_d11generic.rpf" root/tune/skyhat "RR-Files/tune_skycycle/skyhat" -current
        run_magicrdr -replace "../update/game/tune_d11generic.rpf" root/tune/ppp "RR-Files/tune_ppp" -current
        run_magicrdr -replace "../update/game/fragments.rpf" root/fragments "RR-Files/fragments_clouds" -current
    else
        echo "Skipping RDR2-styled timecycle, color scheme and weathers..."
    fi

    if yesno_prompt "Install Reality Redemption fixes and improvements? (better physics, increased spawn rates of peds, tumbleweeds, increased fire distance, etc...) [Y/N]: "; then
        run_magicrdr -replace "../update/game/mapres.rpf" root/mapres "RR-Files/mapres_rr" -current
        run_magicrdr -replace "../update/game/content.rpf" root/content/ambient "RR-Files/content/ambient" -current
        run_magicrdr -replace "../update/game/tune_d11generic.rpf" root/tune/debris "RR-Files/tune/debris" -current
        run_magicrdr -replace "../update/game/tune_d11generic.rpf" root/tune/fire "RR-Files/tune/fire" -current
        run_magicrdr -replace "../update/game/tune_d11generic.rpf" root/tune/materials "RR-Files/tune/materials" -current
        run_magicrdr -replace "../update/game/tune_d11generic.rpf" root/tune/physics "RR-Files/tune/physics" -current
        run_magicrdr -replace "../update/game/tune_d11generic.rpf" root/tune/trees "RR-Files/tune/trees" -current
    else
        echo "Skipping Reality Redemption fixes and improvements..."
    fi

    echo ""
    echo ""
    echo "Installation went according to Dutch's plan! enjoy the mangos at Tahiti."
    echo ""
    echo ""
    pause_key
    exit 0
}

install_automatic() {
    echo "The installation will take some time, please be patient..."
    sleep 2

    cd "$SCRIPT_DIR" || exit
    cp -f "RR-Files/plugins/RedDeadRedemption.FusionMod.asi" "$GAME_DIR/plugins/" 2>/dev/null || true
    cp -f "RR-Files/plugins/RedDeadRedemption.FusionMod.ini" "$GAME_DIR/plugins/" 2>/dev/null || true
    echo ""
    echo "Installed Fusion Mod"

    run_magicrdr -replace "../update/game/mapres.rpf" root/mapres "RR-Files/mapres_loadingscreens" -current
    echo ""
    echo "Installed HD loading screens"

    run_magicrdr -replace "../update/game/mapres.rpf" root/mapres "RR-Files/mapres_minimap" -current
    echo ""
    echo "Installed HD lore-accurate minimap"

    run_magicrdr -replace "../update/game/mapres.rpf" root/mapres "RR-Files/mapres_terrain" -current
    run_magicrdr -replace "../update/game/mapres.rpf" root/mapres "RR-Files/mapres_smics" -current
    run_magicrdr -replace "../update/game/fragments.rpf" root/fragments "RR-Files/fragments_vegetation" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/armadillo.rpf" root/armadillo/armadillo "RR-Files/territory_swall/armadillo/armadillo" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/beechershope.rpf" root/beechershope/beechershope "RR-Files/territory_swall/beechershope/beechershope" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/beechershope.rpf" root/beechershope/beh_house01x "RR-Files/territory_swall/beechershope/beh_house01x" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/blackwater.rpf" root/blackwater/blackwater "RR-Files/territory_swall/blackwater/blackwater" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/chuparosa.rpf" root/chuparosa/chuparosa "RR-Files/territory_swall/chuparosa/chuparosa" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/escalara.rpf" root/escalara/escalara "RR-Files/territory_swall/escalara/escalara" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/fortmercer.rpf" root/fortmercer/fortmercer "RR-Files/territory_swall/fortmercer/fortmercer" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_barn01props01x "RR-Files/territory_swall/hennigansranch/hen_barn01props01x" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_barn01x "RR-Files/territory_swall/hennigansranch/hen_barn01x" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_barn02props01x "RR-Files/territory_swall/hennigansranch/hen_barn02props01x" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_barn02x "RR-Files/territory_swall/hennigansranch/hen_barn02x" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_blacksmith01props01x "RR-Files/territory_swall/hennigansranch/hen_blacksmith01props01x" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_blacksmith01x "RR-Files/territory_swall/hennigansranch/hen_blacksmith01x" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_bridge01x "RR-Files/territory_swall/hennigansranch/hen_bridge01x" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_bunkhouse01props01x "RR-Files/territory_swall/hennigansranch/hen_bunkhouse01props01x" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_bunkhouse01x "RR-Files/territory_swall/hennigansranch/hen_bunkhouse01x" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_bunkhouse02x "RR-Files/territory_swall/hennigansranch/hen_bunkhouse02x" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_cottage01props01x "RR-Files/territory_swall/hennigansranch/hen_cottage01props01x" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_cottage01x "RR-Files/territory_swall/hennigansranch/hen_cottage01x" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_cottage02props01x "RR-Files/territory_swall/hennigansranch/hen_cottage02props01x" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_cottage02x "RR-Files/territory_swall/hennigansranch/hen_cottage02x" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_cottage03props01x "RR-Files/territory_swall/hennigansranch/hen_cottage03props01x" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_cottage03x "RR-Files/territory_swall/hennigansranch/hen_cottage03x" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_entrancefence01x "RR-Files/territory_swall/hennigansranch/hen_entrancefence01x" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_flags01x "RR-Files/territory_swall/hennigansranch/hen_flags01x" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_garden01x "RR-Files/territory_swall/hennigansranch/hen_garden01x" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_henniganshouse01props01x "RR-Files/territory_swall/hennigansranch/hen_henniganshouse01props01x" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_henniganshouse01props02x "RR-Files/territory_swall/hennigansranch/hen_henniganshouse01props02x" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_henniganshouse01x "RR-Files/territory_swall/hennigansranch/hen_henniganshouse01x" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_outhouse01x "RR-Files/territory_swall/hennigansranch/hen_outhouse01x" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_shootinggallery01x "RR-Files/territory_swall/hennigansranch/hen_shootinggallery01x" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_shootinggalleryprops01x "RR-Files/territory_swall/hennigansranch/hen_shootinggalleryprops01x" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_stable01b "RR-Files/territory_swall/hennigansranch/hen_stable01b" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_stable01props01x "RR-Files/territory_swall/hennigansranch/hen_stable01props01x" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_stable01x "RR-Files/territory_swall/hennigansranch/hen_stable01x" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_stable02props01x "RR-Files/territory_swall/hennigansranch/hen_stable02props01x" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_stable02x "RR-Files/territory_swall/hennigansranch/hen_stable02x" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_stable03props01x "RR-Files/territory_swall/hennigansranch/hen_stable03props01x" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_stable03x "RR-Files/territory_swall/hennigansranch/hen_stable03x" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_stockade01props01x "RR-Files/territory_swall/hennigansranch/hen_stockade01props01x" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_stockade01x "RR-Files/territory_swall/hennigansranch/hen_stockade01x" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_store01props01x "RR-Files/territory_swall/hennigansranch/hen_store01props01x" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_store01x "RR-Files/territory_swall/hennigansranch/hen_store01x" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_trainstation01props01x "RR-Files/territory_swall/hennigansranch/hen_trainstation01props01x" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_trainstation01x "RR-Files/territory_swall/hennigansranch/hen_trainstation01x" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hen_watertower01x "RR-Files/territory_swall/hennigansranch/hen_watertower01x" -current
    run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" root/hennigansranch/hennigansranch "RR-Files/territory_swall/hennigansranch/hennigansranch" -current
    echo ""
    echo "Installed HD game world textures (ground, roads, trails, trees, cliffs, buildings, props, etc..)"

    run_magicrdr -replace "../update/game/mapres.rpf" root/mapres "RR-Files/mapres_player" -current
    echo ""
    echo "Installed HD John Marston textures"

    run_magicrdr -replace "../update/game/fragments.rpf" root/fragments "RR-Files/fragments" -current
    echo ""
    echo "Installed HD secondary characters and generic ped textures"

    run_magicrdr -replace "../update/game/grassres.rpf" root/grassres "RR-Files/grassres" -current
    echo ""
    echo "Installed HD RDR2-styled grass textures"

    run_magicrdr -replace "../update/game/naturalmotion.rpf" root/naturalmotion "RR-Files/naturalmotion" -current
    run_magicrdr -replace "../update/game/content.rpf" root/content/ai "RR-Files/content/ai" -current
    echo ""
    echo "Installed Enhanced Euphoria ragdoll behaviours"

    run_magicrdr -replace "../update/game/camera.rpf" root/camera "RR-Files/camera" -current
    echo ""
    echo "Installed RDR2-styled Camera"

    run_magicrdr -replace "../update/game/tune_d11generic.rpf" root/tune/skyhat "RR-Files/tune_skycycle/skyhat" -current
    run_magicrdr -replace "../update/game/tune_d11generic.rpf" root/tune/ppp "RR-Files/tune_ppp" -current
    run_magicrdr -replace "../update/game/fragments.rpf" root/fragments "RR-Files/fragments_clouds" -current
    echo ""
    echo "Installed RDR2-styled timecycle, color scheme and weathers"

    run_magicrdr -replace "../update/game/mapres.rpf" root/mapres "RR-Files/mapres_rr" -current
    run_magicrdr -replace "../update/game/content.rpf" root/content/ambient "RR-Files/content/ambient" -current
    run_magicrdr -replace "../update/game/tune_d11generic.rpf" root/tune/debris "RR-Files/tune/debris" -current
    run_magicrdr -replace "../update/game/tune_d11generic.rpf" root/tune/fire "RR-Files/tune/fire" -current
    run_magicrdr -replace "../update/game/tune_d11generic.rpf" root/tune/materials "RR-Files/tune/materials" -current
    run_magicrdr -replace "../update/game/tune_d11generic.rpf" root/tune/physics "RR-Files/tune/physics" -current
    run_magicrdr -replace "../update/game/tune_d11generic.rpf" root/tune/trees "RR-Files/tune/trees" -current
    echo ""
    echo "Installed Reality Redemption fixes and improvements (better physics, increased spawn rates of peds, tumbleweeds, increased fire distance, etc...)"
    echo ""
    echo ""
    echo "Installation went according to Dutch's plan! enjoy the mangos at Tahiti."
    echo ""
    echo ""
    pause_key
    exit 0
}

# ============================================================================
# UNINSTALL FLOW
# ============================================================================
uninstall_reality_redemption() {
    echo ""
    echo ""
    echo "Checking to see if the installer can find the game files in the update folder..."
    sleep 2
    echo ""

    local required_files=(
        "$GAME_DIR/update/game/camera.rpf"
        "$GAME_DIR/update/game/content.rpf"
        "$GAME_DIR/update/game/fragments.rpf"
        "$GAME_DIR/update/game/grassres.rpf"
        "$GAME_DIR/update/game/mapres.rpf"
        "$GAME_DIR/update/game/naturalmotion.rpf"
        "$GAME_DIR/update/game/navres.rpf"
        "$GAME_DIR/update/game/tune_d11generic.rpf"
    )
    for f in "${required_files[@]}"; do
        if [[ ! -f "$f" ]]; then
            missing_uninstall_files
        fi
    done

    create_rr_temp_dirs
    echo "Found all of the necessary files! proceeding with the uninstallation as planned."
    sleep 2
    clear

    echo "[1] Uninstall Automatically (Uninstall every mod feature)"
    echo "[2] Uninstall Manually (Handpick features)"
    echo "[3] Cancel and Exit"
    echo ""
    echo ""
    read -r -n 1 -p "It's time to choose: " choice
    echo
    case "$choice" in
        1) uninstall_automatic ;;
        2) uninstall_manual ;;
        3) echo ""; echo "I had a god damn PLAN! Press any key to exit..."; pause_key; exit 0 ;;
        *) uninstall_reality_redemption ;;
    esac
}

uninstall_manual() {
    echo ""
    echo "The installer will now ask you which features of the mod you would like to uninstall..."
    echo ""
    echo ""
    sleep 2

    cd "$SCRIPT_DIR" || exit

    if yesno_prompt "Uninstall Fusion Mod? (Skip intro) [Y/N]: "; then
        rm -f "$GAME_DIR/plugins/RedDeadRedemption.FusionMod.asi" 2>/dev/null || true
        rm -f "$GAME_DIR/plugins/RedDeadRedemption.FusionMod.ini" 2>/dev/null || true
        echo "Uninstalled Fusion Mod."
    else
        echo "Skipping Fusion Mod..."
    fi

    if yesno_prompt "Uninstall HD loading screens? [Y/N]: "; then
        run_magicrdr -extractdir "../game/mapres.rpf" root/mapres "RR-Temp/mapres"
        for i in $(seq 1 50); do
            [[ -f "RR-Temp/mapres/ls_$i.wtd" ]] && mv -f "RR-Temp/mapres/ls_$i.wtd" "RR-Temp/mapres_loadingscreens/" 2>/dev/null || true
        done
        run_magicrdr -replace "../update/game/mapres.rpf" root/mapres "RR-Temp/mapres_loadingscreens" -current
    else
        echo "Skipping HD loading screens..."
    fi

    if yesno_prompt "Uninstall HD lore-accurate minimap? [Y/N]: "; then
        run_magicrdr -extractdir "../game/mapres.rpf" root/mapres "RR-Temp/mapres"
        for i in $(seq 1 108); do
            [[ -f "RR-Temp/mapres/streaming_worldmap_$i.wtd" ]] && mv -f "RR-Temp/mapres/streaming_worldmap_$i.wtd" "RR-Temp/mapres_minimap/" 2>/dev/null || true
        done
        [[ -f "RR-Temp/mapres/lodstreamingmap.wtd" ]] && mv -f "RR-Temp/mapres/lodstreamingmap.wtd" "RR-Temp/mapres_minimap/" 2>/dev/null || true
        run_magicrdr -replace "../update/game/mapres.rpf" root/mapres "RR-Temp/mapres_minimap" -current
    else
        echo "Skipping HD lore-accurate minimap..."
    fi

    if yesno_prompt "Uninstall HD game world textures? (ground, roads, trails, trees, cliffs, buildings, props, etc..) [Y/N]: "; then
        run_magicrdr -extractdir "../game/mapres.rpf" root/mapres "RR-Temp/mapres"
        for f in RR-Temp/mapres/*_hilod.wtd RR-Temp/mapres/smic_*.wtd RR-Temp/mapres/terraintrails_*.wtd RR-Temp/mapres/ground_*.wtd RR-Temp/mapres/road_*.wtd RR-Temp/mapres/wet_*.wtd RR-Temp/mapres/rr_*.wtd; do
            [[ -f "$f" ]] && mv -f "$f" "RR-Temp/mapres_terrain/" 2>/dev/null || true
        done
        run_magicrdr -replace "../update/game/mapres.rpf" root/mapres "RR-Temp/mapres_terrain" -current
        for f in RR-Temp/mapres/smic_agaveviejo.wtd RR-Temp/mapres/smic_amb_gunbelt01_01.wtd RR-Temp/mapres/smic_armadillo.wtd RR-Temp/mapres/smic_chuparosa.wtd RR-Temp/mapres/smic_escalera.wtd RR-Temp/mapres/smic_fortdiego.wtd RR-Temp/mapres/smic_hennigans_ranch.wtd RR-Temp/mapres/smic_thieves_landing.wtd; do
            [[ -f "$f" ]] && mv -f "$f" "RR-Temp/mapres_smics/" 2>/dev/null || true
        done
        run_magicrdr -replace "../update/game/mapres.rpf" root/mapres "RR-Temp/mapres_smics" -current
        run_magicrdr -extractfile "../game/fragments.rpf" root/fragments/st_fanpalm01x.wft "RR-Temp/fragments_vegetation/st_fanpalm01x.wft"
        run_magicrdr -extractfile "../game/fragments.rpf" root/fragments/st_liveoak01x.wft "RR-Temp/fragments_vegetation/st_liveoak01x.wft"
        run_magicrdr -extractfile "../game/fragments.rpf" root/fragments/st_palmetto01x.wft "RR-Temp/fragments_vegetation/st_palmetto01x.wft"
        run_magicrdr -replace "../update/game/fragments.rpf" root/fragments "RR-Temp/fragments_vegetation" -current
        run_magicrdr -extractfile "../game/redemption/territory_swall/armadillo.rpf" root/armadillo/armadillo/armadillo.wvd "RR-Temp/territory_swall/armadillo/armadillo/armadillo.wvd"
        run_magicrdr -replace "../update/game/redemption/territory_swall/armadillo.rpf" root/armadillo/armadillo "RR-Temp/territory_swall/armadillo/armadillo" -current
        run_magicrdr -extractfile "../game/redemption/territory_swall/beechershope.rpf" root/beechershope/beechershope/beechershope.wvd "RR-Temp/territory_swall/beechershope/beechershope/beechershope.wvd"
        run_magicrdr -replace "../update/game/redemption/territory_swall/beechershope.rpf" root/beechershope/beechershope "RR-Temp/territory_swall/beechershope/beechershope" -current
        run_magicrdr -extractfile "../game/redemption/territory_swall/beechershope.rpf" root/beechershope/beh_house01x/beh_house01x.wvd "RR-Temp/territory_swall/beechershope/beh_house01x/beh_house01x.wvd"
        run_magicrdr -replace "../update/game/redemption/territory_swall/beechershope.rpf" root/beechershope/beh_house01x "RR-Temp/territory_swall/beechershope/beh_house01x" -current
        run_magicrdr -extractfile "../game/redemption/territory_swall/blackwater.rpf" root/blackwater/blackwater/blackwater.wvd "RR-Temp/territory_swall/blackwater/blackwater/blackwater.wvd"
        run_magicrdr -replace "../update/game/redemption/territory_swall/blackwater.rpf" root/blackwater/blackwater "RR-Temp/territory_swall/blackwater/blackwater" -current
        run_magicrdr -extractfile "../game/redemption/territory_swall/chuparosa.rpf" root/chuparosa/chuparosa/chuparosa.wvd "RR-Temp/territory_swall/chuparosa/chuparosa/chuparosa.wvd"
        run_magicrdr -replace "../update/game/redemption/territory_swall/chuparosa.rpf" root/chuparosa/chuparosa "RR-Temp/territory_swall/chuparosa/chuparosa" -current
        run_magicrdr -extractfile "../game/redemption/territory_swall/escalara.rpf" root/escalara/escalara/escalara.wvd "RR-Temp/territory_swall/escalara/escalara/escalara.wvd"
        run_magicrdr -replace "../update/game/redemption/territory_swall/escalara.rpf" root/escalara/escalara "RR-Temp/territory_swall/escalara/escalara" -current
        run_magicrdr -extractfile "../game/redemption/territory_swall/fortmercer.rpf" root/fortmercer/fortmercer/fortmercer.wvd "RR-Temp/territory_swall/fortmercer/fortmercer/fortmercer.wvd"
        run_magicrdr -replace "../update/game/redemption/territory_swall/fortmercer.rpf" root/fortmercer/fortmercer "RR-Temp/territory_swall/fortmercer/fortmercer" -current
        local hen_extracts=(hen_barn01props01x:hen_barn01props01x hen_barn01x:hen_barn01x hen_barn02props01x:hen_barn02props01x hen_barn02x:hen_barn02x hen_blacksmith01props01x:hen_blacksmith01props01x hen_blacksmith01x:hen_blacksmith01x hen_bridge01x:hen_bridge01x hen_bunkhouse01props01x:hen_bunkhouse01props01x hen_bunkhouse01x:hen_bunkhouse01x hen_bunkhouse02x:hen_bunkhouse02x hen_cottage01props01x:hen_cottage01props01x hen_cottage01x:hen_cottage01x hen_cottage02props01x:hen_cottage02props01x hen_cottage02x:hen_cottage02x hen_cottage03props01x:hen_cottage03props01 hen_cottage03x:hen_cottage03x hen_entrancefence01x:hen_entrancefence01x hen_flags01x:hen_flags01x hen_garden01x:hen_garden01x hen_henniganshouse01props01x:hen_henniganshouse01props01x hen_henniganshouse01props02x:hen_henniganshouse01props02x hen_henniganshouse01x:hen_henniganshouse01x hen_outhouse01x:hen_outhouse01x hen_shootinggallery01x:hen_shootinggallery01x hen_shootinggalleryprops01x:hen_shootinggalleryprops01x hen_stable01b:hen_stable01b hen_stable01props01x:hen_stable01props01x hen_stable01x:hen_stable01x hen_stable02props01x:hen_stable02props01x hen_stable02x:hen_stable02x hen_stable03props01x:hen_stable03props01x hen_stable03x:hen_stable03x hen_stockade01props01x:hen_stockade01props01x hen_stockade01x:hen_stockade01x hen_store01props01x:hen_store01props01x hen_store01x:hen_store01x hen_trainstation01props01x:hen_trainstation01props01x hen_trainstation01x:hen_trainstation01x hen_watertower01x:hen_watertower01x hennigansranch:hennigansranch)
        for pair in "${hen_extracts[@]}"; do
            dir="${pair%%:*}"
            file="${pair##*:}"
            run_magicrdr -extractfile "../game/redemption/territory_swall/hennigansranch.rpf" "root/hennigansranch/$dir/$file.wvd" "RR-Temp/territory_swall/hennigansranch/$dir/$file.wvd" 2>/dev/null || true
            run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" "root/hennigansranch/$dir" "RR-Temp/territory_swall/hennigansranch/$dir" -current
        done
    else
        echo "Skipping HD game world textures..."
    fi

    if yesno_prompt "Uninstall HD John Marston textures? [Y/N]: "; then
        run_magicrdr -extractdir "../game/mapres.rpf" root/mapres "RR-Temp/mapres"
        for f in RR-Temp/mapres/smic_player_*.wtd; do
            [[ -f "$f" ]] && mv -f "$f" "RR-Temp/mapres_player/" 2>/dev/null || true
        done
        run_magicrdr -replace "../update/game/mapres.rpf" root/mapres "RR-Temp/mapres_player" -current
    else
        echo "Skipping HD John Marston textures..."
    fi

    if yesno_prompt "Uninstall HD secondary characters and generic ped textures? [Y/N]: "; then
        run_magicrdr -extractfile "../game/fragments.rpf" root/fragments/anc_firstoldfriendmp_hilod.wfd "RR-Temp/fragments/anc_firstoldfriendmp_hilod.wfd"
        run_magicrdr -extractfile "../game/fragments.rpf" root/fragments/anc_jake_hilod.wfd "RR-Temp/fragments/anc_jake_hilod.wfd"
        run_magicrdr -extractfile "../game/fragments.rpf" root/fragments/fragmenttexturelist.wtd "RR-Temp/fragments/fragmenttexturelist.wtd"
        run_magicrdr -replace "../update/game/fragments.rpf" root/fragments "RR-Temp/fragments" -current
    else
        echo "Skipping HD secondary and generic ped textures..."
    fi

    if yesno_prompt "Uninstall HD RDR2-styled grass textures? [Y/N]: "; then
        run_magicrdr -extractfile "../game/grassres.rpf" root/grassres/grtd_gap.wtd "RR-Temp/grassres/grtd_gap.wtd"
        run_magicrdr -extractfile "../game/grassres.rpf" root/grassres/grtd_grt.wtd "RR-Temp/grassres/grtd_grt.wtd"
        run_magicrdr -extractfile "../game/grassres.rpf" root/grassres/grtd_hen.wtd "RR-Temp/grassres/grtd_hen.wtd"
        run_magicrdr -replace "../update/game/grassres.rpf" root/grassres "RR-Temp/grassres" -current
    else
        echo "Skipping HD grass textures..."
    fi

    if yesno_prompt "Uninstall Enhanced Euphoria ragdoll behaviours? [Y/N]: "; then
        run_magicrdr -extractfile "../game/naturalmotion.rpf" root/naturalmotion/behaviours.xml "RR-Temp/naturalmotion/behaviours.xml"
        run_magicrdr -extractfile "../game/naturalmotion.rpf" root/naturalmotion/cowboy.nmbehaviours.xml "RR-Temp/naturalmotion/cowboy.nmbehaviours.xml"
        run_magicrdr -extractfile "../game/content.rpf" root/content/ai/movementtuning.xml "RR-Temp/content/ai/movementtuning.xml"
        run_magicrdr -replace "../update/game/naturalmotion.rpf" root/naturalmotion "RR-Temp/naturalmotion" -current
        run_magicrdr -replace "../update/game/content.rpf" root/content/ai "RR-Temp/content/ai" -current
    else
        echo "Skipping enhanced ragdoll behaviours..."
    fi

    if yesno_prompt "Uninstall RDR2-styled Camera? [Y/N]: "; then
        run_magicrdr -extractfile "../game/camera.rpf" root/camera/cameralenspresets.txt "RR-Temp/camera/cameralenspresets.txt"
        run_magicrdr -extractfile "../game/camera.rpf" root/camera/fovspline.cmt "RR-Temp/camera/fovspline.cmt"
        run_magicrdr -extractfile "../game/camera.rpf" root/camera/tune.xml "RR-Temp/camera/tune.xml"
        run_magicrdr -replace "../update/game/camera.rpf" root/camera "RR-Temp/camera" -current
    else
        echo "Skipping RDR2-styled Camera..."
    fi

    if yesno_prompt "Uninstall RDR2-styled timecycle, color scheme and weathers? [Y/N]: "; then
        run_magicrdr -extractfile "../game/tune_d11generic.rpf" root/tune/skyhat/kfskyhat_clear.xml "RR-Temp/tune_skycycle/skyhat/kfskyhat_clear.xml"
        run_magicrdr -extractfile "../game/tune_d11generic.rpf" root/tune/skyhat/kfskyhat_fair.xml "RR-Temp/tune_skycycle/skyhat/kfskyhat_fair.xml"
        run_magicrdr -replace "../update/game/tune_d11generic.rpf" root/tune/skyhat "RR-Temp/tune_skycycle/skyhat" -current
        run_magicrdr -extractfile "../game/tune_d11generic.rpf" root/tune/ppp/default.ppp "RR-Temp/tune_ppp/default.ppp"
        run_magicrdr -replace "../update/game/tune_d11generic.rpf" root/tune/ppp "RR-Temp/tune_ppp" -current
        run_magicrdr -extractfile "../game/fragments.rpf" root/fragments/skyhat_cloudy01x.wft "RR-Temp/fragments_clouds/skyhat_cloudy01x.wft"
        run_magicrdr -extractfile "../game/fragments.rpf" root/fragments/skyhat_cloudy06x.wft "RR-Temp/fragments_clouds/skyhat_cloudy06x.wft"
        run_magicrdr -extractfile "../game/fragments.rpf" root/fragments/skyhat_cloudy07x.wft "RR-Temp/fragments_clouds/skyhat_cloudy07x.wft"
        run_magicrdr -extractfile "../game/fragments.rpf" root/fragments/skyhat_fog01x.wft "RR-Temp/fragments_clouds/skyhat_fog01x.wft"
        run_magicrdr -extractfile "../game/fragments.rpf" root/fragments/skyhat_rainy01x.wft "RR-Temp/fragments_clouds/skyhat_rainy01x.wft"
        run_magicrdr -extractfile "../game/fragments.rpf" root/fragments/skyhat_rainy02x.wft "RR-Temp/fragments_clouds/skyhat_rainy02x.wft"
        run_magicrdr -extractfile "../game/fragments.rpf" root/fragments/skyhat_stormy01x.wft "RR-Temp/fragments_clouds/skyhat_stormy01x.wft"
        run_magicrdr -replace "../update/game/fragments.rpf" root/fragments "RR-Temp/fragments_clouds" -current
    else
        echo "Skipping RDR2-styled timecycle, color scheme and weathers..."
    fi

    if yesno_prompt "Uninstall Reality Redemption fixes and improvements? (better physics, increased spawn rates of peds, tumbleweeds, increased fire distance, etc...) [Y/N]: "; then
        run_magicrdr -extractfile "../game/mapres.rpf" root/mapres/mapblips.wtd "RR-Temp/mapres_rr/mapblips.wtd"
        run_magicrdr -extractfile "../game/mapres.rpf" root/mapres/swall.wtd "RR-Temp/mapres_rr/swall.wtd"
        run_magicrdr -extractfile "../game/mapres.rpf" root/mapres/textback.wtd "RR-Temp/mapres_rr/textback.wtd"
        run_magicrdr -replace "../update/game/mapres.rpf" root/mapres "RR-Temp/mapres_rr" -current
        run_magicrdr -extractfile "../game/content.rpf" root/content/ambient/placementglobals.xml "RR-Temp/content/ambient/placementglobals.xml"
        run_magicrdr -replace "../update/game/content.rpf" root/content/ambient "RR-Temp/content/ambient" -current
        run_magicrdr -extractfile "../game/tune_d11generic.rpf" root/tune/debris/debris.tune "RR-Temp/tune/debris/debris.tune"
        run_magicrdr -extractfile "../game/tune_d11generic.rpf" root/tune/debris/tumbleweeds.xml "RR-Temp/tune/debris/tumbleweeds.xml"
        run_magicrdr -replace "../update/game/tune_d11generic.rpf" root/tune/debris "RR-Temp/tune/debris" -current
        run_magicrdr -extractfile "../game/tune_d11generic.rpf" root/tune/fire/fire.tune "RR-Temp/tune/fire/fire.tune"
        run_magicrdr -replace "../update/game/tune_d11generic.rpf" root/tune/fire "RR-Temp/tune/fire" -current
        run_magicrdr -extractfile "../game/tune_d11generic.rpf" root/tune/materials/cloth.mtl "RR-Temp/tune/materials/cloth.mtl"
        run_magicrdr -extractfile "../game/tune_d11generic.rpf" root/tune/materials/prop_cactus.mtl "RR-Temp/tune/materials/prop_cactus.mtl"
        run_magicrdr -extractfile "../game/tune_d11generic.rpf" root/tune/materials/prop_cloth.mtl "RR-Temp/tune/materials/prop_cloth.mtl"
        run_magicrdr -extractfile "../game/tune_d11generic.rpf" root/tune/materials/water.mtl "RR-Temp/tune/materials/water.mtl"
        run_magicrdr -replace "../update/game/tune_d11generic.rpf" root/tune/materials "RR-Temp/tune/materials" -current
        run_magicrdr -extractfile "../game/tune_d11generic.rpf" root/tune/physics/liquid.xml "RR-Temp/tune/physics/liquid.xml"
        run_magicrdr -extractfile "../game/tune_d11generic.rpf" root/tune/physics/physics.xml "RR-Temp/tune/physics/physics.xml"
        run_magicrdr -replace "../update/game/tune_d11generic.rpf" root/tune/physics "RR-Temp/tune/physics" -current
        run_magicrdr -extractfile "../game/tune_d11generic.rpf" root/tune/trees/treetypesettings.xml "RR-Temp/tune/trees/treetypesettings.xml"
        run_magicrdr -replace "../update/game/tune_d11generic.rpf" root/tune/trees "RR-Temp/tune/trees" -current
    else
        echo "Skipping Reality Redemption fixes and improvements..."
    fi

    if yesno_prompt "Delete the update folder? (This can remove other mods you may have installed as well, basically reverting everything to vanilla) [Y/N]: "; then
        [[ -d "$GAME_DIR/update" ]] && rm -rf "$GAME_DIR/update"
        echo "Deleted the update folder."
    else
        echo "Skipping deleting the update folder..."
    fi

    echo ""
    echo ""
    rm -rf "$SCRIPT_DIR/RR-Temp"
    echo "Uninstallation went according to Agent Milton's plan! no mangos and Tahiti for you."
    echo ""
    echo ""
    pause_key
    exit 0
}

uninstall_automatic() {
    echo "The uninstallation will take some time, please be patient..."
    sleep 2

    cd "$SCRIPT_DIR" || exit
    rm -f "$GAME_DIR/plugins/RedDeadRedemption.FusionMod.asi" 2>/dev/null || true
    rm -f "$GAME_DIR/plugins/RedDeadRedemption.FusionMod.ini" 2>/dev/null || true
    echo ""
    echo "Uninstalled Fusion Mod"

    run_magicrdr -extractdir "../game/mapres.rpf" root/mapres "RR-Temp/mapres"
    for i in $(seq 1 50); do
        [[ -f "RR-Temp/mapres/ls_$i.wtd" ]] && mv -f "RR-Temp/mapres/ls_$i.wtd" "RR-Temp/mapres_loadingscreens/" 2>/dev/null || true
    done
    run_magicrdr -replace "../update/game/mapres.rpf" root/mapres "RR-Temp/mapres_loadingscreens" -current
    echo ""
    echo "Uninstalled HD loading screens"

    run_magicrdr -extractdir "../game/mapres.rpf" root/mapres "RR-Temp/mapres"
    for i in $(seq 1 108); do
        [[ -f "RR-Temp/mapres/streaming_worldmap_$i.wtd" ]] && mv -f "RR-Temp/mapres/streaming_worldmap_$i.wtd" "RR-Temp/mapres_minimap/" 2>/dev/null || true
    done
    [[ -f "RR-Temp/mapres/lodstreamingmap.wtd" ]] && mv -f "RR-Temp/mapres/lodstreamingmap.wtd" "RR-Temp/mapres_minimap/" 2>/dev/null || true
    run_magicrdr -replace "../update/game/mapres.rpf" root/mapres "RR-Temp/mapres_minimap" -current
    echo ""
    echo "Uninstalled HD lore-accurate minimap"

    run_magicrdr -extractdir "../game/mapres.rpf" root/mapres "RR-Temp/mapres"
    for f in RR-Temp/mapres/*_hilod.wtd RR-Temp/mapres/smic_*.wtd RR-Temp/mapres/terraintrails_*.wtd RR-Temp/mapres/ground_*.wtd RR-Temp/mapres/road_*.wtd RR-Temp/mapres/wet_*.wtd RR-Temp/mapres/rr_*.wtd; do
        [[ -f "$f" ]] && mv -f "$f" "RR-Temp/mapres_terrain/" 2>/dev/null || true
    done
    run_magicrdr -replace "../update/game/mapres.rpf" root/mapres "RR-Temp/mapres_terrain" -current
    for f in RR-Temp/mapres/smic_agaveviejo.wtd RR-Temp/mapres/smic_armadillo.wtd RR-Temp/mapres/smic_chuparosa.wtd RR-Temp/mapres/smic_escalera.wtd RR-Temp/mapres/smic_fortdiego.wtd RR-Temp/mapres/smic_hennigans_ranch.wtd RR-Temp/mapres/smic_thieves_landing.wtd; do
        [[ -f "$f" ]] && mv -f "$f" "RR-Temp/mapres_smics/" 2>/dev/null || true
    done
    run_magicrdr -replace "../update/game/mapres.rpf" root/mapres "RR-Temp/mapres_smics" -current
    run_magicrdr -extractfile "../game/fragments.rpf" root/fragments/st_fanpalm01x.wft "RR-Temp/fragments_vegetation/st_fanpalm01x.wft"
    run_magicrdr -extractfile "../game/fragments.rpf" root/fragments/st_liveoak01x.wft "RR-Temp/fragments_vegetation/st_liveoak01x.wft"
    run_magicrdr -extractfile "../game/fragments.rpf" root/fragments/st_palmetto01x.wft "RR-Temp/fragments_vegetation/st_palmetto01x.wft"
    run_magicrdr -replace "../update/game/fragments.rpf" root/fragments "RR-Temp/fragments_vegetation" -current
    run_magicrdr -extractfile "../game/redemption/territory_swall/armadillo.rpf" root/armadillo/armadillo/armadillo.wvd "RR-Temp/territory_swall/armadillo/armadillo/armadillo.wvd"
    run_magicrdr -replace "../update/game/redemption/territory_swall/armadillo.rpf" root/armadillo/armadillo "RR-Temp/territory_swall/armadillo/armadillo" -current
    run_magicrdr -extractfile "../game/redemption/territory_swall/beechershope.rpf" root/beechershope/beechershope/beechershope.wvd "RR-Temp/territory_swall/beechershope/beechershope/beechershope.wvd"
    run_magicrdr -replace "../update/game/redemption/territory_swall/beechershope.rpf" root/beechershope/beechershope "RR-Temp/territory_swall/beechershope/beechershope" -current
    run_magicrdr -extractfile "../game/redemption/territory_swall/beechershope.rpf" root/beechershope/beh_house01x/beh_house01x.wvd "RR-Temp/territory_swall/beechershope/beh_house01x/beh_house01x.wvd"
    run_magicrdr -replace "../update/game/redemption/territory_swall/beechershope.rpf" root/beechershope/beh_house01x "RR-Temp/territory_swall/beechershope/beh_house01x" -current
    run_magicrdr -extractfile "../game/redemption/territory_swall/blackwater.rpf" root/blackwater/blackwater/blackwater.wvd "RR-Temp/territory_swall/blackwater/blackwater/blackwater.wvd"
    run_magicrdr -replace "../update/game/redemption/territory_swall/blackwater.rpf" root/blackwater/blackwater "RR-Temp/territory_swall/blackwater/blackwater" -current
    run_magicrdr -extractfile "../game/redemption/territory_swall/chuparosa.rpf" root/chuparosa/chuparosa/chuparosa.wvd "RR-Temp/territory_swall/chuparosa/chuparosa/chuparosa.wvd"
    run_magicrdr -replace "../update/game/redemption/territory_swall/chuparosa.rpf" root/chuparosa/chuparosa "RR-Temp/territory_swall/chuparosa/chuparosa" -current
    run_magicrdr -extractfile "../game/redemption/territory_swall/escalara.rpf" root/escalara/escalara/escalara.wvd "RR-Temp/territory_swall/escalara/escalara/escalara.wvd"
    run_magicrdr -replace "../update/game/redemption/territory_swall/escalara.rpf" root/escalara/escalara "RR-Temp/territory_swall/escalara/escalara" -current
    run_magicrdr -extractfile "../game/redemption/territory_swall/fortmercer.rpf" root/fortmercer/fortmercer/fortmercer.wvd "RR-Temp/territory_swall/fortmercer/fortmercer/fortmercer.wvd"
    run_magicrdr -replace "../update/game/redemption/territory_swall/fortmercer.rpf" root/fortmercer/fortmercer "RR-Temp/territory_swall/fortmercer/fortmercer" -current
    local hen_extracts=(
        "hen_barn01props01x:hen_barn01props01x" "hen_barn01x:hen_barn01x" "hen_barn02props01x:hen_barn02props01x" "hen_barn02x:hen_barn02x"
        "hen_blacksmith01props01x:hen_blacksmith01props01x" "hen_blacksmith01x:hen_blacksmith01x" "hen_bridge01x:hen_bridge01x"
        "hen_bunkhouse01props01x:hen_bunkhouse01props01x" "hen_bunkhouse01x:hen_bunkhouse01x" "hen_bunkhouse02x:hen_bunkhouse02x"
        "hen_cottage01props01x:hen_cottage01props01x" "hen_cottage01x:hen_cottage01x" "hen_cottage02props01x:hen_cottage02props01x" "hen_cottage02x:hen_cottage02x"
        "hen_cottage03props01x:hen_cottage03props01" "hen_cottage03x:hen_cottage03x" "hen_entrancefence01x:hen_entrancefence01x" "hen_flags01x:hen_flags01x"
        "hen_garden01x:hen_garden01x" "hen_henniganshouse01props01x:hen_henniganshouse01props01x" "hen_henniganshouse01props02x:hen_henniganshouse01props02x"
        "hen_henniganshouse01x:hen_henniganshouse01x" "hen_outhouse01x:hen_outhouse01x" "hen_shootinggallery01x:hen_shootinggallery01x"
        "hen_shootinggalleryprops01x:hen_shootinggalleryprops01x" "hen_stable01b:hen_stable01b" "hen_stable01props01x:hen_stable01props01x"
        "hen_stable01x:hen_stable01x" "hen_stable02props01x:hen_stable02props01x" "hen_stable02x:hen_stable02x"
        "hen_stable03props01x:hen_stable03props01x" "hen_stable03x:hen_stable03x" "hen_stockade01props01x:hen_stockade01props01x"
        "hen_stockade01x:hen_stockade01x" "hen_store01props01x:hen_store01props01x" "hen_store01x:hen_store01x"
        "hen_trainstation01props01x:hen_trainstation01props01x" "hen_trainstation01x:hen_trainstation01x" "hen_watertower01x:hen_watertower01x"
        "hennigansranch:hennigansranch"
    )
    for pair in "${hen_extracts[@]}"; do
        dir="${pair%%:*}"
        file="${pair##*:}"
        run_magicrdr -extractfile "../game/redemption/territory_swall/hennigansranch.rpf" "root/hennigansranch/$dir/$file.wvd" "RR-Temp/territory_swall/hennigansranch/$dir/$file.wvd" 2>/dev/null || true
        run_magicrdr -replace "../update/game/redemption/territory_swall/hennigansranch.rpf" "root/hennigansranch/$dir" "RR-Temp/territory_swall/hennigansranch/$dir" -current
    done
    echo ""
    echo "Uninstalled HD game world textures"

    run_magicrdr -extractdir "../game/mapres.rpf" root/mapres "RR-Temp/mapres"
    for f in RR-Temp/mapres/smic_player_*.wtd; do
        [[ -f "$f" ]] && mv -f "$f" "RR-Temp/mapres_player/" 2>/dev/null || true
    done
    run_magicrdr -replace "../update/game/mapres.rpf" root/mapres "RR-Temp/mapres_player" -current
    echo ""
    echo "Uninstalled HD John Marston textures"

    run_magicrdr -extractfile "../game/fragments.rpf" root/fragments/fragmenttexturelist.wtd "RR-Temp/fragments/fragmenttexturelist.wtd"
    run_magicrdr -replace "../update/game/fragments.rpf" root/fragments "RR-Temp/fragments" -current
    echo ""
    echo "Uninstalled HD secondary characters and generic ped textures"

    run_magicrdr -extractfile "../game/grassres.rpf" root/grassres/grtd_gap.wtd "RR-Temp/grassres/grtd_gap.wtd"
    run_magicrdr -extractfile "../game/grassres.rpf" root/grassres/grtd_grt.wtd "RR-Temp/grassres/grtd_grt.wtd"
    run_magicrdr -extractfile "../game/grassres.rpf" root/grassres/grtd_hen.wtd "RR-Temp/grassres/grtd_hen.wtd"
    run_magicrdr -replace "../update/game/grassres.rpf" root/grassres "RR-Temp/grassres" -current
    echo ""
    echo "Uninstalled HD grass textures"

    run_magicrdr -extractfile "../game/naturalmotion.rpf" root/naturalmotion/behaviours.xml "RR-Temp/naturalmotion/behaviours.xml"
    run_magicrdr -extractfile "../game/naturalmotion.rpf" root/naturalmotion/cowboy.nmbehaviours.xml "RR-Temp/naturalmotion/cowboy.nmbehaviours.xml"
    run_magicrdr -extractfile "../game/content.rpf" root/content/ai/movementtuning.xml "RR-Temp/content/ai/movementtuning.xml"
    run_magicrdr -replace "../update/game/naturalmotion.rpf" root/naturalmotion "RR-Temp/naturalmotion" -current
    run_magicrdr -replace "../update/game/content.rpf" root/content/ai "RR-Temp/content/ai" -current
    echo ""
    echo "Uninstalled Enhanced Euphoria ragdoll behaviours"

    run_magicrdr -extractfile "../game/camera.rpf" root/camera/cameralenspresets.txt "RR-Temp/camera/cameralenspresets.txt"
    run_magicrdr -extractfile "../game/camera.rpf" root/camera/fovspline.cmt "RR-Temp/camera/fovspline.cmt"
    run_magicrdr -extractfile "../game/camera.rpf" root/camera/tune.xml "RR-Temp/camera/tune.xml"
    run_magicrdr -replace "../update/game/camera.rpf" root/camera "RR-Temp/camera" -current
    echo ""
    echo "Uninstalled RDR2-styled Camera"

    run_magicrdr -extractfile "../game/tune_d11generic.rpf" root/tune/skyhat/kfskyhat_clear.xml "RR-Temp/tune_skycycle/skyhat/kfskyhat_clear.xml"
    run_magicrdr -extractfile "../game/tune_d11generic.rpf" root/tune/skyhat/kfskyhat_fair.xml "RR-Temp/tune_skycycle/skyhat/kfskyhat_fair.xml"
    run_magicrdr -replace "../update/game/tune_d11generic.rpf" root/tune/skyhat "RR-Temp/tune_skycycle/skyhat" -current
    run_magicrdr -extractfile "../game/tune_d11generic.rpf" root/tune/ppp/default.ppp "RR-Temp/tune_ppp/default.ppp"
    run_magicrdr -replace "../update/game/tune_d11generic.rpf" root/tune/ppp "RR-Temp/tune_ppp" -current
    run_magicrdr -extractfile "../game/fragments.rpf" root/fragments/skyhat_cloudy01x.wft "RR-Temp/fragments_clouds/skyhat_cloudy01x.wft"
    run_magicrdr -extractfile "../game/fragments.rpf" root/fragments/skyhat_cloudy06x.wft "RR-Temp/fragments_clouds/skyhat_cloudy06x.wft"
    run_magicrdr -extractfile "../game/fragments.rpf" root/fragments/skyhat_cloudy07x.wft "RR-Temp/fragments_clouds/skyhat_cloudy07x.wft"
    run_magicrdr -extractfile "../game/fragments.rpf" root/fragments/skyhat_fog01x.wft "RR-Temp/fragments_clouds/skyhat_fog01x.wft"
    run_magicrdr -extractfile "../game/fragments.rpf" root/fragments/skyhat_rainy01x.wft "RR-Temp/fragments_clouds/skyhat_rainy01x.wft"
    run_magicrdr -extractfile "../game/fragments.rpf" root/fragments/skyhat_rainy02x.wft "RR-Temp/fragments_clouds/skyhat_rainy02x.wft"
    run_magicrdr -extractfile "../game/fragments.rpf" root/fragments/skyhat_stormy01x.wft "RR-Temp/fragments_clouds/skyhat_stormy01x.wft"
    run_magicrdr -replace "../update/game/fragments.rpf" root/fragments "RR-Temp/fragments_clouds" -current
    echo ""
    echo "Uninstalled RDR2-styled timecycle, color scheme and weathers"

    run_magicrdr -extractfile "../game/mapres.rpf" root/mapres/mapblips.wtd "RR-Temp/mapres_rr/mapblips.wtd"
    run_magicrdr -extractfile "../game/mapres.rpf" root/mapres/swall.wtd "RR-Temp/mapres_rr/swall.wtd"
    run_magicrdr -extractfile "../game/mapres.rpf" root/mapres/textback.wtd "RR-Temp/mapres_rr/textback.wtd"
    run_magicrdr -replace "../update/game/mapres.rpf" root/mapres "RR-Temp/mapres_rr" -current
    run_magicrdr -extractfile "../game/content.rpf" root/content/ambient/placementglobals.xml "RR-Temp/content/ambient/placementglobals.xml"
    run_magicrdr -replace "../update/game/content.rpf" root/content/ambient "RR-Temp/content/ambient" -current
    run_magicrdr -extractfile "../game/tune_d11generic.rpf" root/tune/debris/debris.tune "RR-Temp/tune/debris/debris.tune"
    run_magicrdr -extractfile "../game/tune_d11generic.rpf" root/tune/debris/tumbleweeds.xml "RR-Temp/tune/debris/tumbleweeds.xml"
    run_magicrdr -replace "../update/game/tune_d11generic.rpf" root/tune/debris "RR-Temp/tune/debris" -current
    run_magicrdr -extractfile "../game/tune_d11generic.rpf" root/tune/fire/fire.tune "RR-Temp/tune/fire/fire.tune"
    run_magicrdr -replace "../update/game/tune_d11generic.rpf" root/tune/fire "RR-Temp/tune/fire" -current
    run_magicrdr -extractfile "../game/tune_d11generic.rpf" root/tune/materials/cloth.mtl "RR-Temp/tune/materials/cloth.mtl"
    run_magicrdr -extractfile "../game/tune_d11generic.rpf" root/tune/materials/prop_cactus.mtl "RR-Temp/tune/materials/prop_cactus.mtl"
    run_magicrdr -extractfile "../game/tune_d11generic.rpf" root/tune/materials/prop_cloth.mtl "RR-Temp/tune/materials/prop_cloth.mtl"
    run_magicrdr -extractfile "../game/tune_d11generic.rpf" root/tune/materials/water.mtl "RR-Temp/tune/materials/water.mtl"
    run_magicrdr -replace "../update/game/tune_d11generic.rpf" root/tune/materials "RR-Temp/tune/materials" -current
    run_magicrdr -extractfile "../game/tune_d11generic.rpf" root/tune/physics/liquid.xml "RR-Temp/tune/physics/liquid.xml"
    run_magicrdr -extractfile "../game/tune_d11generic.rpf" root/tune/physics/physics.xml "RR-Temp/tune/physics/physics.xml"
    run_magicrdr -replace "../update/game/tune_d11generic.rpf" root/tune/physics "RR-Temp/tune/physics" -current
    run_magicrdr -extractfile "../game/tune_d11generic.rpf" root/tune/trees/treetypesettings.xml "RR-Temp/tune/trees/treetypesettings.xml"
    run_magicrdr -replace "../update/game/tune_d11generic.rpf" root/tune/trees "RR-Temp/tune/trees" -current
    echo ""
    echo "Uninstalled Reality Redemption fixes and improvements"

    echo ""
    echo ""
    rm -rf "$SCRIPT_DIR/RR-Temp"
    echo "Uninstallation went according to Agent Milton's plan! no mangos and Tahiti for you."
    echo ""
    echo ""
    pause_key
    exit 0
}

# ============================================================================
# ENTRY POINT
# ============================================================================
main_menu
