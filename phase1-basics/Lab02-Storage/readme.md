# Lab 02: File System & Storage

## 🎯 Objective

Learn how to manage disk partitions, format file systems, mount drives, and configure persistent storage in Linux.

## 📋 Prerequisites

- Ubuntu VM running
- Root or sudo access
- Basic command line knowledge
- Completed Lab 01: User & Permission Management

## 🔧 Lab Environment

- **OS**: Ubuntu 22.04 LTS
- **VM**: VirtualBox
- **Additional Disk**: 10GB virtual disk (to be added)
- **Time**: 45-60 minutes

## 📝 Tasks

### Task 1: Check Current Disk Status
**Steps in VirtualBox:**
- Used `df -h` to view disk space usage in a human-readable format  
- Executed `lsblk` to identify available disks and partitions  
- Ran `sudo fdisk -l` to inspect disk partition tables  
- Verified mounted filesystems using `mount | grep "^/dev"`  
- Confirmed overall disk health and storage configuration



```bash
# View disk usage
df -h

# List all block devices
lsblk

# Check disk partitions
sudo fdisk -l

# View mounted filesystems
mount | grep "^/dev"
```

**Screenshot:**
![Disk Status Before](./screenshots/01-disk-status-before-01.png)
**Screenshot:**
![Disk Status Before](./screenshots/01-disk-status-before-02.png)
**Screenshot:**
![Disk Status Before](./screenshots/01-disk-status-before-03.png)

---

### Task 2: Add New Virtual Disk

**Steps in VirtualBox:**
1. Power off your Ubuntu VM
2. Go to VM Settings → Storage
3. Click the "+" icon next to "Controller: SATA"
4. Choose "Create new disk"
5. Set size to 10GB
6. Start the VM

**Verification:**
```bash
# Check if new disk is detected
lsblk
# Should see /dev/sdb (new 10GB disk)

sudo fdisk -l /dev/sdb
```

**Screenshot:**
![New Disk Added](./screenshots/02-new-disk-added.png)

---

### Task 3: Partition the New Disk
```bash
# Start fdisk for the new disk
sudo fdisk /dev/sdb

# Inside fdisk interactive mode:
# n    (create new partition)
# p    (primary partition)
# 1    (partition number)
# Enter (default first sector)
# Enter (default last sector - uses all space)
# w    (write changes and exit)
```

**Verification:**
```bash
# Check the new partition
lsblk
sudo fdisk -l /dev/sdb

# Should see /dev/sdb1
```

**Screenshot:**
![Partition Created](./screenshots/03-partition-created.png)

---

### Task 4: Format the Partition
```bash
# Format as ext4 filesystem
sudo mkfs.ext4 /dev/sdb1

# View filesystem info
sudo file -s /dev/sdb1
sudo blkid /dev/sdb1
```

**Expected Output:**
```
/dev/sdb1: UUID="xxxx-xxxx-xxxx-xxxx" TYPE="ext4"
```

**Screenshot:**
![Filesystem Formatted](./screenshots/04-filesystem-formatted.png)

---

### Task 5: Create Mount Point and Mount
```bash
# Create mount point directory
sudo mkdir -p /data

# Mount the partition temporarily
sudo mount /dev/sdb1 /data

# Verify it's mounted
df -h | grep /data
mount | grep /data
lsblk
```

**Test the mount:**
```bash
# Create a test file
sudo touch /data/test-file.txt
echo "This is a test" | sudo tee /data/test-file.txt

# List contents
ls -l /data/
cat /data/test-file.txt
```

**Screenshot:**
![Disk Mounted](./screenshots/05-disk-mounted.png)

---

### Task 6: Configure Persistent Mount (Auto-mount on Boot)
```bash
# Get the UUID of the partition
sudo blkid /dev/sdb1
# Copy the UUID value

# Backup fstab before editing
sudo cp /etc/fstab /etc/fstab.backup

# Edit fstab
sudo nano /etc/fstab

# Add this line at the end (replace UUID with your actual UUID):
# UUID=your-uuid-here /data ext4 defaults 0 2
```

**Example fstab entry:**
```
UUID=12345678-1234-1234-1234-123456789abc /data ext4 defaults 0 2
```

**Verify fstab syntax:**
```bash
# Test fstab without rebooting
sudo umount /data
sudo mount -a

# Check if it mounted correctly
df -h | grep /data
```

**Screenshot:**
![fstab Configuration](./screenshots/06-fstab-configured.png)

---

### Task 7: Test Automatic Mount After Reboot
```bash
# Reboot the system
sudo reboot

# After reboot, check if /data is automatically mounted
df -h | grep /data
ls -l /data/
cat /data/test-file.txt
```

**Screenshot:**
![Auto-mount After Reboot](./screenshots/07-auto-mount-verified.png)

---

### Task 8: Check Disk Usage and Inodes
```bash
# Check disk space usage
df -h

# Check inode usage
df -i

# Check specific directory size
du -sh /data
du -h /data

# Check disk I/O statistics
iostat
# If iostat not found: sudo apt install sysstat
```

**Screenshot:**
![Disk Usage](./screenshots/08-disk-usage.png)

---

## 📊 Results

| Task | Status | Notes |
|------|--------|-------|
| Disk Status Check | ✅ | Identified existing disks |
| Virtual Disk Added | ✅ | 10GB disk added as /dev/sdb |
| Partition Created | ✅ | /dev/sdb1 created successfully |
| Filesystem Formatted | ✅ | ext4 filesystem created |
| Manual Mount | ✅ | Mounted to /data |
| Persistent Mount | ✅ | fstab configured correctly |
| Auto-mount Test | ✅ | Survives reboot |
| Usage Verification | ✅ | All commands working |

---

## 🐛 Troubleshooting

### Issue: New disk not showing up
**Solution:**
```bash
# Rescan for new hardware
sudo partprobe

# Or check VirtualBox settings
# Make sure VM is powered off when adding disk
```

### Issue: "mount: wrong fs type" error
**Solution:**
```bash
# Check filesystem type
sudo blkid /dev/sdb1

# Reformat if needed
sudo mkfs.ext4 -f /dev/sdb1
```

### Issue: Mount fails after reboot
**Solution:**
```bash
# Check fstab syntax
sudo mount -a

# Restore backup if needed
sudo cp /etc/fstab.backup /etc/fstab

# Verify UUID is correct
sudo blkid /dev/sdb1
```

### Issue: Permission denied when writing to /data
**Solution:**
```bash
# Change ownership
sudo chown -R $USER:$USER /data

# Or adjust permissions
sudo chmod 755 /data
```

---

## 💡 What I Learned

1. **Disk Management**
   - How to add virtual disks in VirtualBox
   - Difference between `/dev/sda`, `/dev/sdb`, etc.
   - Understanding block devices with `lsblk`

2. **Partitioning**
   - Using `fdisk` for partition creation
   - Primary vs extended vs logical partitions
   - MBR vs GPT partition tables

3. **Filesystems**
   - ext4 is the default Linux filesystem
   - Other options: ext3, xfs, btrfs
   - Formatting destroys all data on partition

4. **Mounting**
   - Temporary mounts with `mount` command
   - Persistent mounts via `/etc/fstab`
   - Importance of UUID over device names

5. **Best Practices**
   - Always backup `/etc/fstab` before editing
   - Use UUIDs instead of device names (more reliable)
   - Test with `mount -a` before rebooting
   - Keep mount points organized (`/data`, `/backup`, etc.)

---



## 📚 Additional Resources

- [Linux Filesystem Hierarchy](https://www.pathname.com/fhs/)
- [Understanding fstab](https://help.ubuntu.com/community/Fstab)
- [ext4 Filesystem Documentation](https://ext4.wiki.kernel.org/)
- [fdisk vs parted](https://www.redhat.com/sysadmin/disk-partition-parted)

---

## ✅ Lab Completion Checklist

- [ ] Checked current disk status
- [ ] Added new 10GB virtual disk
- [ ] Created partition with fdisk
- [ ] Formatted partition as ext4
- [ ] Mounted partition manually
- [ ] Configured persistent mount in fstab
- [ ] Tested auto-mount after reboot
- [ ] Verified disk usage commands
- [ ] Documented all steps
- [ ] Added screenshots
- [ ] Created automation scripts
- [ ] Uploaded to GitHub

---

**Completed:** January 01, 2026  
**Previous Lab:** [Lab 01 - User & Permission Management](../Lab01-User-Permission/)  
**Next Lab:** [Lab 03 - Package Management](../lab03-packages/)
