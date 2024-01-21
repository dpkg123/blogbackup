---
title: twrp设备树从入门到放弃
date: 2023-12-10 10:41:08
description: "虽然但是，安卓设备树比这个难。"
tags:
- twrp
- android 
- linux
- build
summary:
---
# ⚠️ 注意：本人非专业 Android 开发者，本文仅供参考，如有错误，欢迎指正！

本文章以适配OPPO Reno5 Pro+ 为例, OPPO Reno5 Pro+ 为 A only 设备, 支持动态分区 , 不兼容 GKI, VNDK 版本 30。

编译服务器系统: Ubuntu 20.04.4 lts


## 需要准备的东西
- 可以编译 Android 的高性能 PC 或服务器(需提前预留32gb的ram和100g的设备存储空间)
- 国际互联网连接
- 一台root过的OPPO Reno5 Pro+
## 准备开始

### 安装编译依赖
```
sudo apt install bc bison build-essential ccache curl flex g++-multilib gcc-multilib git gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev libelf-dev liblz4-tool libncurses5 libncurses5-dev libsdl1.2-dev libssl-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev git
```
## 配置 repo
```
sudo curl https://storage.googleapis.com/git-repo-downloads/repo > /usr/bin/repo
sudo chmod a+x /usr/bin/repo
```
## 同步 TWRP 源码
```
mkdir twrp && cd twrp
repo init -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni -b twrp-9.0 --depth=1
repo sync
```
如果安卓版本为安卓10及其以上，请更换网址为:
```
repo init -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp -b twrp-12.1 --depth=1
```
注:如果同时安转了python2.7和python3，运行repo时可能会出现以下状况:
```
File "/usr/bin/repo", line 51
    def print(self, *args, **kwargs):
            ^
SyntaxError: invalid syntax
```
解决方法:
```
/usr/bin/python3 /usr/bin/repo sync
```
或修改 /usr/bin/repo
```
#!/bin/python
```
改成
``` bash
#!/bin/python3
```
源码同步成功后会占用磁盘20g-30g的空间。

## 初始化编译必要文件
> ⚠️ 注意：下列步骤将由xxxx替代要适配的手机代号，yyyy代替手机厂商。

不管是编译 Android 还是 TWRP，这些文件都是必要的:
- Android.mk
- AndroidProduct.mk
- BoardConfig.mk
- twrp_xxxx.mk 
这几个文件可以直接从其他的twrp设备树拿，然后进行修改。

Android.mk、AndroidProduct.mk、twrp_xxxx.mk 一般情况下无需进行修改

编译 TWRP 需要对 BoardConfig.mk 等文件进行修改

## 修改 BoardConfig.mk

```
DEVICE_PATH := device/yyyy/xxxx
```

此处定义了设备树的位置。
```
ALLOW_MISSING_DEPENDENCIES := true
```
由于同步的只有 TWRP 源码，编译时需要打开这个。
```
BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true
```
这两个选项可能会解决一些编译错误。当有两个或更多的条目试图将文件复制到相同的目标位置时。这个标志的作用是允许覆盖先前定义的目标命令，而不是报错。
```
# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := kryo385

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := generic
TARGET_2ND_CPU_VARIANT_RUNTIME := kryo385
```
这里定义要适配的机型的cpu的一些信息。
```
TARGET_BOARD_SUFFIX := _64
TARGET_USES_64_BIT_BINDER := true
```
如果适配的安卓设备的soc是64位soc，且系统也是64位，请启用它。
```
TARGET_OTA_ASSERT_DEVICE := xxxx
```
此处定义了设备ota时候的机型代号，ota机型检查的时候会检查是否匹配。
```
# Bootloader
PRODUCT_PLATFORM := kona
TARGET_BOOTLOADER_BOARD_NAME := kona
TARGET_NO_BOOTLOADER := true
TARGET_USES_UEFI := true
```
此处定义了bootloader的一些信息。
```
BOARD_USES_MTK_HARDWARE := true
BOARD_HAS_MTK_HARDWARE := true
```
这两个选项仅适用于mtk芯片组。
```
# Platform
TARGET_BOARD_PLATFORM := sm8250
```
此处定义了cpu的代号。
```
# BOARD_BOOTIMG_HEADER_VERSION := 2
# BOARD_KERNEL_BASE := 0x40078000
# BOARD_KERNEL_CMDLINE := ttyMSM0,115200n8 earlycon=msm_geni_serial,0xa90000 androidboot.hardware=qcom androidboot.console=ttyMSM0 androidboot.memcg=1 lpm_levels.sleep_disabled=1 video=vfb:640x400,bpp=32,memsize=3072000 msm_rtb.filter=0x237 service_locator.enable=1 androidboot.usbcontroller=a600000.dwc3 swiotlb=2048 loop.max_part=7 cgroup.memory=nokmem,nosocket reboot=panic_warm kpti=off buildvariant=user
# BOARD_KERNEL_PAGESIZE := 2048
# BOARD_RAMDISK_OFFSET := 0x11088000
# BOARD_KERNEL_TAGS_OFFSET := 0x07c08000
# BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOTIMG_HEADER_VERSION)
# BOARD_MKBOOTIMG_ARGS += --ramdisk_offset $(BOARD_RAMDISK_OFFSET)
# BOARD_MKBOOTIMG_ARGS += --tags_offset $(BOARD_KERNEL_TAGS_OFFSET)
# BOARD_KERNEL_IMAGE_NAME := Image
# BOARD_INCLUDE_DTB_IN_BOOTIMG := true
# BOARD_KERNEL_SEPARATED_DTBO := true
# TARGET_KERNEL_CONFIG := xxxx_defconfig
# TARGET_KERNEL_SOURCE := device/yyyy/xxxx
```
使用源码编译才使用此部分。
```
BOARD_KERNEL_CMDLINE := ttyMSM0,115200n8 earlycon=msm_geni_serial,0xa90000 androidboot.hardware=qcom androidboot.console=ttyMSM0 androidboot.memcg=1 lpm_levels.sleep_disabled=1 video=vfb:640x400,bpp=32,memsize=3072000 msm_rtb.filter=0x237 service_locator.enable=1 androidboot.usbcontroller=a600000.dwc3 swiotlb=2048 loop.max_part=7 cgroup.memory=nokmem,nosocket reboot=panic_warm kpti=off buildvariant=user
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/kernel
TARGET_PREBUILT_DTB := $(DEVICE_PATH)/prebuilt/dtb.img
BOARD_PREBUILT_DTBOIMAGE := $(DEVICE_PATH)/prebuilt/dtbo.img
BOARD_INCLUDE_RECOVERY_DTBO := true
BOARD_BOOTIMG_HEADER_VERSION := 2
BOARD_RAMDISK_OFFSET := 0x11088000
BOARD_KERNEL_BASE := 0x40078000
BOARD_KERNEL_TAGS_OFFSET := 0x07c08000
BOARD_KERNEL_PAGESIZE := 2048
BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOTIMG_HEADER_VERSION)
BOARD_MKBOOTIMG_ARGS += --ramdisk_offset $(BOARD_RAMDISK_OFFSET)
BOARD_MKBOOTIMG_ARGS += --tags_offset $(BOARD_KERNEL_TAGS_OFFSET)
BOARD_MKBOOTIMG_ARGS += --dtb $(TARGET_PREBUILT_DTB)
BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOTIMG_HEADER_VERSION)
BOARD_KERNEL_IMAGE_NAME := kernel
```
使用预编译内核。你需要提取手机的boot.img并使用[Android Image Kitchen](https://github.com/osm0sis/Android-Image-Kitchen)来获取预编译内核，dtb和dtbo(如果有)以及cmdline。

然后替换cmdline。

再将预编译内核放入引用的路径。这里引用的路径是`$(DEVICE_PATH)/prebuilt/`
```
# Android Verified Boot
BOARD_AVB_ENABLE := true
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --set_hashtree_disabled_flag
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 2
BOARD_AVB_RECOVERY_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_RECOVERY_ALGORITHM := SHA256_RSA4096
BOARD_AVB_RECOVERY_ROLLBACK_INDEX := 1
BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION := 1
BOARD_AVB_VBMETA_SYSTEM := product system
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX_LOCATION := 1
```
此处定义了avb的一些信息。
```
# Metadata
BOARD_USES_METADATA_PARTITION := true
```
在twrp中使用metadata分区。
```
# Hack: prevent anti rollback
PLATFORM_SECURITY_PATCH := 2127-12-31
```
加入补丁更新日期来回避防回滚机制。
```
# Partitions
BOARD_FLASH_BLOCK_SIZE := 262144
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 134217728
BOARD_BOOTIMAGE_PARTITION_SIZE := 167772160
```
此处定义了boot分区和recovery分区的大小，以及块大小。修改分区大小时要注意单位是b而不是kb。
```
# Dynamic Partition
BOARD_SUPER_PARTITION_SIZE := 10200547328
BOARD_SUPER_PARTITION_GROUPS := qti_dynamic_partitions
BOARD_QTI_DYNAMIC_PARTITIONS_SIZE := 10200547328
BOARD_QTI_DYNAMIC_PARTITIONS_PARTITION_LIST := system system_ext product vendor odm
```
此处定义了动态分区的信息。可按需修改。
```
# File systems
BOARD_HAS_LARGE_FILESYSTEM := true
BOARD_SYSTEMIMAGE_PARTITION_TYPE := ext4
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
TARGET_COPY_OUT_VENDOR := vendor
```
此处依次定义了system，vendor和data分区的文件系统，以及vendor分区的相对路径。
```
# Fstab
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery/root/system/etc/recovery.fstab
```
此处定义了fstab的位置。可提取recovery中的ramdisk.cpio中的进行使用。
```
# TWRP Configuration
TW_THEME := portrait_hdpi
TW_BRIGHTNESS_PATH := "/sys/devices/soc/c900000.qcom\x2cmdss_mdp/c900000.qcom\x2cmdss_mdp:qcom\x2cmdss_fb_primary/leds/lcd-backlight/brightness" 
TW_MAX_BRIGHTNESS := 255
TW_DEFAULT_BRIGHTNESS := 155
TW_EXTRA_LANGUAGES := ture
TW_IGNORE_MISC_WIPE_DATA := true
TW_SCREEN_BLANK_ON_BOOT := true
TW_NO_EXFAT_FUSE := true
TW_INCLUDE_CRYPTO := true
TARGET_CRYPTFS_HW_PATH := vendor/qcom/opensource/commonsys/cryptfs_hw
```
此处依次定义了twrp要使用的主题，亮度调节的内核节点，亮度调节，添加亚洲语言， 是否在 wipe data 时忽略 misc，是否添加加密，解密所需依赖源码路径等信息。

注:亮度调节的内核节点语言根据本机的位置进行修改。
```
TW_USE_TOOLBOX := true 
TWRP_INCLUDE_LOGCAT := true 
TARGET_USES_LOGD := true 
```
此处定义了twrp是否启用调试功能，例如toolbox,logcat等。
```
# Include some binaries
TW_INCLUDE_LIBRESETPROP := true
TW_INCLUDE_RESETPROP := true
TW_INCLUDE_REPACKTOOLS := true
```
此处定义twrp编译时引用的第三方库。
```
TARGET_USES_MKE2FS := true
```
此处添加了mke2fs，可将分区格式化成f2fs。
```
TW_DEFAULT_LANGUAGE := zh_CN
```
此处设置了启动twrp时的默认语言为中文。
```
TW_OZIP_DECRYPT_KEY := 0000
```
此处定义了刷入ozip时解密ozip的秘钥。
```
AB_OTA_UPDATER := true
BOARD_USES_RECOVERY_AS_BOOT := true
BOARD_BUILD_SYSTEM_ROOT_IMAGE := true
```
如果是 A/B 分区的话还得加入这些。

## 修改 device.mk
```
LOCAL_PATH := device/yyyy/xxxx
```
定义local_path变量，一般有这一行就够了。
```
PRODUCT_USE_DYNAMIC_PARTITIONS := true
```
是否启用动态分区。如果设备是动态分区就启用。
```
# Crypto
PRODUCT_PACKAGES += \
    qcom_decrypt \
    qcom_decrypt_fbe
```
此处添加解密所需依赖。
```
# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
	$(LOCAL_PATH)
```
此处定义Soong namespaces的路径。

注:下述内容需要设备为A/B分区。
```
AB_OTA_UPDATER := true
```
此处定义了是否启用A/B支持。
```
AB_OTA_PARTITIONS += \
    boot \
    system \
    vendor
```
此处定义了使用 A/B 特性的分
```
AB_OTA_POSTINSTALL_CONFIG += \ 
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=ext4 \
    POSTINSTALL_OPTIONAL_system=true
```
此处定义了A/B分区ota的一些选项。
```
PRODUCT_PACKAGES += \
    otapreopt_script \
    cppreopts.sh \
    update_engine \
    update_verifier \
    update_engine_sideload

# Boot control
PRODUCT_PACKAGES += \
    android.hardware.boot@1.0-impl \
    android.hardware.boot@1.0-service \
    bootctrl.sm8250 \

PRODUCT_PACKAGES_DEBUG += \
    bootctl

PRODUCT_STATIC_BOOT_CONTROL_HAL := \
    bootctrl.sm8250 \
    libcutils \
    libgptutils \
    libz
```
此处定义了需要引用的包。

修改完成后，在 twrp_xxxx.mk 里调用
```
$(call inherit-product, device/yyyy/xxxx/device.mk)
```
## 配置 TWRP 分区表
可以从本机recovery里提取一份recovery.fstab并放在之前引用的位置。我这里引用的是`recovery/root/system/etc/recovery fastb`

然后新建文件twrp.flags并放在`与recovery.fastb相同的路径`。

twrp.flags文件示例:
```
# mount point   fstype     device                                   device2                       flags
# 定义挂载点  定义文件系统类型 定义挂载原块文件路径                                                       定义一些特性
# Other partitions
/boot           emmc    /dev/block/bootdevice/by-name/boot             flags=backup=1;display="Boot";flashimg=1
/recovery       emmc    /dev/block/bootdevice/by-name/recovery         flags=backup=1;display="Recovery";flashimg=1
/dtbo           emmc    /dev/block/bootdevice/by-name/dtbo             flags=backup=1;display="Dtbo";flashimg=1
/cache          ext4    /dev/block/bootdevice/by-name/cache            flags=backup=1;display="Cache";wipeingui
/metadata       ext4    /dev/block/bootdevice/by-name/metadata         flags=display="Metadata";wrappedkey
/data           f2fs    /dev/block/bootdevice/by-name/userdata         flags=fileencryption=aes-256-xts:aes-256-cts:v2+inlinecrypt_optimized+wrappedkey_v0,metadata_encryption=aes-256-xts:wrappedkey_v0,keydirectory=/metadata/vold/metadata_encryption

# System
/system 			ext4	/dev/block/bootdevice/by-name/system		flags=slotselect;display="System";backup=1;wipeingui
/system_image	        	emmc	/dev/block/bootdevice/by-name/system		flags=slotselect;flashimg=1
/vendor				ext4	/dev/block/bootdevice/by-name/vendor		flags=slotselect;display="Vendor";backup=1;wipeingui
/vendor_image		        emmc	/dev/block/bootdevice/by-name/vendor		flags=slotselect;flashimg=1
/product			ext4	/dev/block/bootdevice/by-name/product		flags=slotselect;display="Product";backup=1
/product_image		        emmc	/dev/block/bootdevice/by-name/product		flags=slotselect;flashimg=1
/odm                            ext4    /dev/block/bootdevice/by-name/odm               display="ODM";logical
/odm_image                	emmc	/dev/block/bootdevice/by-name/odm       	flags=display="ODM";flashimg;backup=1
/system_ext                     ext4    /dev/block/bootdevice/by-name/system_ext        logical
/system_ext_image		emmc	/dev/block/bootdevice/by-name/system_ext	flags=slotselect;flashimg=1

/system                         erofs   /dev/block/bootdevice/by-name/system            display="system";logical
/vendor                         erofs   /dev/block/bootdevice/by-name/vendor            display="Vendor";logical
/product                        erofs   /dev/block/bootdevice/by-name/product           display="Product";logical
/odm                            erofs   /dev/block/bootdevice/by-name/odm               display="ODM";logical
/system_ext                     erofs   /dev/block/bootdevice/by-name/system_ext        display="system_ext";logical

/usbstorage     vfat       /dev/block/sdg1
```

关于 flags:
- 如果是 A/B 设备，请给使用 A/B 特性的分区定义 `slotselect`
- 用 backup 来定义可备份分区
- display 用来自定义分区名
- encryptable 来定义加密类型
- removable 用来定义可否热拔插

如果是A/B分区，还需要添加`recovery.wipe`:
```
# All the partitions to be wiped (in order) under recovery.
/dev/block/bootdevice/by-name/system_a
/dev/block/bootdevice/by-name/system_b
/dev/block/bootdevice/by-name/vendor_a
/dev/block/bootdevice/by-name/vendor_b
/dev/block/bootdevice/by-name/userdata
# Wipe the boot partitions last so that all partitions will be wiped
# correctly even if the wiping process gets interrupted by a force boot.
/dev/block/bootdevice/by-name/boot_a
/dev/block/bootdevice/by-name/boot_b
```
## init.rc
不同机型，init 部分也不一样

可以复制recovery.img里面的

## bootctrl 和 gpt-utils
如果你的设备采用 A/B 分区，那必须编译这两个组件

确保 tree 里面有编译 bootctrl 和 gpt-utils

这两个东西可以从其它机型的 tree 里面拿，通用的

## 开始编译
上面的东西都配置好后就可以开始编译了
```
cd twrp
. build/envsetup.sh
lunch twrp_xxxx-eng
mka bootimage
```
如果设备不是 A/B 分区
```
mka recoveryimage
```
## 制作卡刷包
需要再BoardConfig.mk加入
```
USE_RECOVERY_INSTALLER := true
RECOVERY_INSTALLER_PATH := device/yyyy/xxxx/installer
```
新建以下目录:
```
installer
installer/META-INF/
installer/META-INF/com
installer/META-INF/com/google
installer/META-INF/com/google/android/
```
添加magiskboot到installer目录

添加update-binary到installer/META-INF/com/google/android/目录:
```
#!/sbin/sh

tmp=/tmp/twrp-install

if [ "$3" ]; then
	zip=$3
	console=/proc/$$/fd/$2
	# write the location of the console buffer to /tmp/console for other scripts to use
	echo "$console" > /tmp/console
else
	console=$(cat /tmp/console)
	[ "$console" ] || console=/proc/$$/fd/1
fi

print() {
	if [ "$1" ]; then
		echo "ui_print $1" > "$console"
	else
		echo "ui_print  " > "$console"
	fi
	echo
}

abort() {
	[ "$1" ] && {
		print "Error: $1"
		print "Aborting..."
	}
	cleanup
	print "Failed to patch boot image!"
	exit 1
}

cleanup() {
	[ "$zip" ] && rm /tmp/console
}

extract() {
	rm -rf "$2"
	mkdir -p "$2"
	unzip -o "$1" -d "$2" || abort "Failed to extract zip to $2!"
}

print "#########################################"
print "#          TWRP installer               #"
print "#########################################"

# Unpack the installer
[ "$zip" ] && {
	print "Unpacking the installer..."
	extract "$zip" "$tmp"
}
cd "$tmp"
toolname="/magiskboot"
tool="$tmp$toolname"
targetfile="/boot.img"
target="$tmp$targetfile"

chmod 755 "$tool"

print "Running boot image patcher on slot A..."
dd if=/dev/block/bootdevice/by-name/boot_a "of=$target"
"$tool" --unpack boot.img
cp -f ramdisk-recovery.cpio ramdisk.cpio
"$tool" --repack boot.img
dd if=new-boot.img of=/dev/block/bootdevice/by-name/boot_a
rm boot.img
rm dtb
rm kernel
rm new-boot.img
rm ramdisk.cpio
print "Running boot image patcher on slot B..."
dd if=/dev/block/bootdevice/by-name/boot_b "of=$target"
"$tool" --unpack boot.img
cp -f ramdisk-recovery.cpio ramdisk.cpio
"$tool" --repack boot.img
dd if=new-boot.img of=/dev/block/bootdevice/by-name/boot_b

print "Boot image patching complete"

#cleanup
print "Done installing TWRP!"
```
注:A/B分区可能需要准备installer/META-INF/MANIFEST.MF，installer/META-INF/CERT.SF，installer/META-INF/CERT.RSA
