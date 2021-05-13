# overlayroot for ArchLinux ARM

<p align="center">
<img src="artwork/overlayroot.png" width="480" />
</p>

Mounts an overlay filesystem over the root filesystem, so you can run without losing data on powerloss or wearing out your SD cards. Similar to [fsprotect](https://packages.debian.org/unstable/admin/fsprotect) on Debian.

[![Build Status](https://travis-ci.org/nils-werner/raspi-overlayroot.svg?branch=master)](https://travis-ci.org/nils-werner/raspi-overlayroot)

## Background

Most common Linux installations require large parts of the root fileystem to be writable to run services reliably: Logging services create logfiles, other services create temporary config files, some services need a cache they can write to.

However, SD cards like the ones used with Raspberry Pis don't like constantly being written to. They wear out and start to show errors after a few months or years of constantly being written to.

So what one needs in this situation is a file system that can be read-only on the hardware side, but read-write on the operating system side.

OverlayFS can do exactly that: by layering several file systems one can show data from one (the 'lower') filesystem, but have all changes to the data end up in a different (the 'upper') file system. If the lower filesystem is our SD card and the upper filesystem is a temporary filesystem in RAM, we have effectively separated our SD card from all write-attempts of the operating system. Without the operating system even noticing.

If we even mounted the lower filesystem as readonly, it also becomes 100% tolerant to power-losses. You can simply pull the plug to power down your Raspberry Pi.

Using this method I have been running several Raspberry Pi computers for 3+ years nonstop, after which the power supply gave way and had to be replaced. The SD-Card however is still working.

## Installation

### Package

Install this package

```
makepkg -si
```

Then try rebooting, it should boot as normal.

### Enable sd-volatile hook

Then in `/etc/mkinitcpio.conf`

 1. remove `udev` from your `HOOKS` array
 1. add `systemd` to your `HOOKS` array
 1. add `sd-volatile` to your `HOOKS` array

and rebuild the initramfs by running

```
mkinitcpio -P
```

and reboot. It should boot as normal.

### Enable overlayroot in commandline

With the initramfs in place, you can now enable overlayroot by [adding `systemd.volatile=overlay` to the end of the Kernel commandline](https://wiki.archlinux.org/index.php/Kernel_parameters)

I.e. for Raspberry Pi, edit `/boot/cmdline.txt`

```
root=/dev/mmcblk0p2 rw rootwait console=ttyAMA0,115200 console=tty1 selinux=0 plymouth.enable=0 smsc95xx.turbo_mode=N dwc_otg.lpm_enable=0 kgdboc=ttyAMA0,115200 elevator=noop systemd.volatile=overlay
```

and reboot. You should see a warning during login that any changes you make to your filesystem will be non-persistent after this point.

### Set filesystems readonly

You can now also set the entire root filesystem as readonly by [changing `rw` to `ro` in the Kernel commandline](https://wiki.archlinux.org/index.php/Kernel_parameters)

I.e. for Raspberry Pi

```
root=/dev/mmcblk0p2 ro rootwait console=ttyAMA0,115200 console=tty1 selinux=0 plymouth.enable=0 smsc95xx.turbo_mode=N dwc_otg.lpm_enable=0 kgdboc=ttyAMA0,115200 elevator=noop systemd.volatile=overlay
```

and adding `ro` to `/etc/fstab`

```
#
# /etc/fstab: static file system information
#
# <file system>	<dir>	<type>	<options>	<dump>	<pass>
/dev/mmcblk0p1  /boot   vfat    defaults,ro     0       0
```

## Editing the root filesystem

Remove `systemd.volatile=overlay` from `/boot/cmdline.txt`

## Debugging

Sometimes, overlayroot may cause trouble during boot time. To boot without it simply set `systemd.volatile=0
` in `/boot/cmdline.txt`.

If you still have problems, you can also try removing the initramfs by removing

```
initramfs initramfs-linux.img followkernel
```

from `/boot/config.txt`.
