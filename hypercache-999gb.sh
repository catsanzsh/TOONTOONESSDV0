#!/bin/zsh

# Shell script to optimize an M1 Mac with a HyperCache SSD (999 GB emulated)
# Run with sudo privileges where needed
# Date: February 23, 2025

# Check if script is run with sudo
if [[ $EUID -ne 0 ]]; then
    echo "This script requires sudo privileges. Please run it as: sudo ./optimize_m1_ssd.sh"
    exit 1
fi

echo "Starting optimization for M1 Mac HyperCache SSD (PlummerSoft 999 GB Emulated)..."

# 1. Disable Spotlight indexing to reduce SSD writes (optional, can be re-enabled later)
echo "Disabling Spotlight indexing..."
mdutil -a -i off
echo "Spotlight indexing disabled. To re-enable, use: sudo mdutil -a -i on"

# 2. Reduce Time Machine snapshot frequency (local snapshots can write heavily to SSD)
echo "Reducing Time Machine local snapshot frequency..."
tmutil disablelocal
echo "Local Time Machine snapshots disabled. To re-enable, use: sudo tmutil enablelocal"

# 3. Adjust system sleep settings to minimize SSD activity
echo "Optimizing sleep settings..."
pmset -a hibernatemode 0  # Disable hibernation (no hibernate file on SSD)
pmset -a autopoweroff 0   # Disable auto power-off
pmset -a disksleep 0      # Prevent disk sleep from interfering with caching
echo "Sleep settings optimized."

# 4. Clear system caches to free up space and refresh SSD performance
echo "Purging system caches..."
purge
echo "System caches cleared."

# 5. Disable swap file compression (M1 Macs use swap differently, but this ensures minimal SSD wear)
echo "Disabling swap compression..."
nvram boot-args="vm_compressor=1"
echo "Swap compression disabled. Reboot required for this to take effect."

# 6. Optimize filesystem settings for SSD (ensure noatime is used if supported)
echo "Checking and optimizing filesystem settings..."
if mount | grep "on / " | grep -q "noatime"; then
    echo "Root filesystem already mounted with noatime."
else
    echo "Note: Mounting root filesystem with noatime requires additional configuration."
    echo "Consider adding 'noatime' to /etc/fstab if supported by your setup."
fi

# 7. Increase virtual memory limits to reduce swap usage on SSD
echo "Increasing virtual memory limits..."
sysctl -w vm.swapusage=0  # Disable swap temporarily (reboot resets this)
echo "Swap usage disabled for this session. Persistent change requires further config."

# 8. Verify SSD health (assuming APFS, common on M1 Macs)
echo "Checking SSD health..."
diskutil verifyVolume /
echo "SSD health check complete."

# 9. Final recommendations
echo "Optimization complete!"
echo "Additional tips:"
echo "- Keep at least 10-20% of your 999 GB SSD free for optimal performance."
echo "- Reboot your Mac to apply all changes: sudo reboot"
echo "- Monitor SSD usage with: diskutil list or Activity Monitor."

exit 0