---
title: PostmarketOS移植常见问题
date: 2024-08-12 10:10:55
tags:
- PostmarketOS
- ROM移植
- linux
- android
- 刷机
---
# 前言
这篇文章简单介绍下我移植k20pro-PostmarketOS出现的问题以及解决方法

移植教程可以参考[这篇文章](https://ivonblog.com/posts/xperia5-ii-postmarketos-porting/)

注:以下问题需要执行`pmbootstrap log`才能找到，或者在pmbootstrap的工作目录里的`log.txt`里找到

建议编译内核前先删除pmbootstrap的工作目录里的`log.txt`

# 问题1: xxx patch无法打补丁
这个问题出现在执行`pmbootstrap kconfig edit`时

解决办法:

在`linux-xiaomi-raphael/APKBUILD`中删除所有.patch字样

# 问题2: asm/type.h :no such file or directory
这个问题出现在执行`pmbootstrap build linux-xiaomi-raphael`时

解决办法:

执行
```bash
$ pmbootstrap chroot
$ apk add linux-headers 
#注:第二条命令需要在第一条命令执行成功后再执行
```

# 问题3: gzip(cpio) command not found
同上

解决办法:

将上面的`linux-headers`换成gzip(cpio)

# 问题4 c语言错误
同上

解决办法:

如果你是c语言大佬，可以试试修复

否则尝逝更换编译器为`clang`

在`linux-xiaomi-raphael/APKBUILD`中添加以下字段
```text
CC="clang"
HOSTCC="clang"
```
或者使用gcc6/gcc4(仅限老旧手机)

在`linux-xiaomi-raphael/APKBUILD`中添加以下字段

```text
# Compiler: GCC 6 (doesn't boot when compiled with newer versions)
if [ "${CC:0:5}" != "gcc6-" ]; then
	CC="gcc6-$CC"
	HOSTCC="gcc6-gcc"
	CROSS_COMPILE="gcc6-$CROSS_COMPILE"
fi
```
如果要使用gcc4,请将上面字段的6改成4

如果还是不行的话，建议更换一个问题较少的内核~~这里着重点名小米，官方内核就是一坨shit~~

# 问题5: Permission denied
这个问题可能出现在执行`pmbootstrap build linux-xiaomi-raphael`或者`pmbootstrap install`的时候

解决办法:

换个目录并将目录权限设置成`755`

```bash
$ chmod 755 $(pmbootstrap_work_dir)
```

# 问题6: xxx.h no such file or directory
这个问题出现在执行`pmbootstrap build linux-xiaomi-raphael`时，且问题多出自与小米官方内核~~雷军，金凡！~~

解决办法:

使用find命令找到缺失的文件然后将文件复制到报错的文件的目录中

# 问题7:../include/linux/compiler-gcc.h:2:2: error: #error "Please don't include <linux/compiler-gcc.h> directly, include <linux/compiler.h> instead."
同上

解决办法:

将`APKBUILD`中的
```text
prepare() {
	default_prepare
	. downstreamkernel_prepare
}
```
换成
```text
prepare() {
	default_prepare
	REPLACE_GCCH=0
	. downstreamkernel_prepare
}
```

# 问题8: losetup: /home/pmos/rootfs/xiaomi-raphael.img: failed to set up loop device: no such file or directory
这个问题出现在执行`pmbootstrap indtall`时

解决办法:

在后面添加`--android-recovery-zip`，只构建卡刷包

# 问题9: deviceinfo: missing dtb
同上

解决办法: 在`deviceinfo中`的`deviceinfo_dtb`选项中添加编译好的dtb路径，一般添加在`$pkgdir/boot/dtbs/`中:

```deviceinfo
deviceinfo_format_version="0"
deviceinfo_name="Xiaomi Redmi K20 Pro"
deviceinfo_manufacturer="Xiaomi"
deviceinfo_codename="xiaomi-raphael"
deviceinfo_year="2019"
deviceinfo_dtb="qcom/sm8150-xiaomi-raphael"
deviceinfo_modules_initfs="gpi i2c_qcom_geni goodix_i2c qcom_pmi8998_charger qcom_fg"
deviceinfo_arch="aarch64"
```

# 问题10: python2: command not found
出现在mkdtboimg中。而且从Alpine3.16开始就不再提供。

解决办法:

1.切换版本到v20.06(不推荐)

2.修改源码，可以参考以下patch:

```diff
From 88cdbae9030bea8e6a7233af3b4adf0d62930498 Mon Sep 17 00:00:00 2001
From: dabao1955 <dabao1955@163.com>
Date: Tue, 6 Aug 2024 20:53:07 +0800
Subject: [PATCH] Makefile.lib: Use Python3 to make dtbo image

Signed-off-by: dabao1955 <dabao1955@163.com>
---
 scripts/Makefile.lib            |   2 +-
 scripts/dtc/libfdt/mkdtboimg.py | 281 ++++++++++----------------------
 2 files changed, 83 insertions(+), 200 deletions(-)

diff --git a/scripts/Makefile.lib b/scripts/Makefile.lib
index f4ba87cfa..de8981871 100644
--- a/scripts/Makefile.lib
+++ b/scripts/Makefile.lib
@@ -310,7 +310,7 @@ dtc-tmp = $(subst $(comma),_,$(dot-target).dts.tmp)
 # mkdtimg
 #----------------------------------------------------------------------------
 quiet_cmd_mkdtimg = DTBOIMG $@
-cmd_mkdtimg = python2 $(srctree)/scripts/dtc/libfdt/mkdtboimg.py create $@ --page_size=4096 $(filter-out FORCE,$^)
+cmd_mkdtimg = python3 $(srctree)/scripts/dtc/libfdt/mkdtboimg.py create $@ --page_size=4096 $(filter-out FORCE,$^)
 
 # cat
 # ---------------------------------------------------------------------------
diff --git a/scripts/dtc/libfdt/mkdtboimg.py b/scripts/dtc/libfdt/mkdtboimg.py
index 03f0fd1b7..7b907da89 100644
--- a/scripts/dtc/libfdt/mkdtboimg.py
+++ b/scripts/dtc/libfdt/mkdtboimg.py
@@ -1,4 +1,4 @@
-#! /usr/bin/env python
+#! /usr/bin/env python3
 # Copyright 2017, The Android Open Source Project
 #
 # Licensed under the Apache License, Version 2.0 (the "License");
@@ -12,51 +12,46 @@
 # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 # See the License for the specific language governing permissions and
 # limitations under the License.
-
 from __future__ import print_function
-
 """Tool for packing multiple DTB/DTBO files into a single image"""
-
 import argparse
+import fnmatch
 import os
+import struct
+import zlib
 from array import array
 from collections import namedtuple
-import struct
 from sys import stdout
-import zlib
-
 class CompressionFormat(object):
     """Enum representing DT compression format for a DT entry.
     """
     NO_COMPRESSION = 0x00
     ZLIB_COMPRESSION = 0x01
     GZIP_COMPRESSION = 0x02
-
 class DtEntry(object):
     """Provides individual DT image file arguments to be added to a DTBO.
-
     Attributes:
-        _REQUIRED_KEYS: 'keys' needed to be present in the dictionary passed to instantiate
-            an object of this class.
-        _COMPRESSION_FORMAT_MASK: Mask to retrieve compression info for DT entry from flags field
+        REQUIRED_KEYS_V0: 'keys' needed to be present in the dictionary passed to instantiate
+            an object of this class when a DTBO header of version 0 is used.
+        REQUIRED_KEYS_V1: 'keys' needed to be present in the dictionary passed to instantiate
+            an object of this class when a DTBO header of version 1 is used.
+        COMPRESSION_FORMAT_MASK: Mask to retrieve compression info for DT entry from flags field
             when a DTBO header of version 1 is used.
     """
-    _COMPRESSION_FORMAT_MASK = 0x0f
-    REQUIRED_KEYS = ('dt_file', 'dt_size', 'dt_offset', 'id', 'rev', 'flags',
-                     'custom0', 'custom1', 'custom2')
-
+    COMPRESSION_FORMAT_MASK = 0x0f
+    REQUIRED_KEYS_V0 = ('dt_file', 'dt_size', 'dt_offset', 'id', 'rev',
+                     'custom0', 'custom1', 'custom2', 'custom3')
+    REQUIRED_KEYS_V1 = ('dt_file', 'dt_size', 'dt_offset', 'id', 'rev',
+                     'flags', 'custom0', 'custom1', 'custom2')
     @staticmethod
     def __get_number_or_prop(arg):
         """Converts string to integer or reads the property from DT image.
-
         Args:
             arg: String containing the argument provided on the command line.
-
         Returns:
             An integer property read from DT file or argument string
             converted to integer
         """
-
         if not arg or arg[0] == '+' or arg[0] == '-':
             raise ValueError('Invalid argument passed to DTImage')
         if arg[0] == '/':
@@ -69,34 +64,37 @@ class DtEntry(object):
             elif arg.startswith('0'):
                 base = 8
             return int(arg, base)
-
     def __init__(self, **kwargs):
         """Constructor for DtEntry object.
-
         Initializes attributes from dictionary object that contains
         values keyed with names equivalent to the class's attributes.
-
         Args:
             kwargs: Dictionary object containing values to instantiate
                 class members with. Expected keys in dictionary are from
                 the tuple (_REQUIRED_KEYS)
         """
-
-        missing_keys = set(self.REQUIRED_KEYS) - set(kwargs)
+        self.__version = kwargs['version']
+        required_keys = None
+        if self.__version == 0:
+            required_keys = self.REQUIRED_KEYS_V0
+        elif self.__version == 1:
+            required_keys = self.REQUIRED_KEYS_V1
+        missing_keys = set(required_keys) - set(kwargs)
         if missing_keys:
             raise ValueError('Missing keys in DtEntry constructor: %r' %
                              sorted(missing_keys))
-
         self.__dt_file = kwargs['dt_file']
         self.__dt_offset = kwargs['dt_offset']
         self.__dt_size = kwargs['dt_size']
         self.__id = self.__get_number_or_prop(kwargs['id'])
         self.__rev = self.__get_number_or_prop(kwargs['rev'])
-        self.__flags = self.__get_number_or_prop(kwargs['flags'])
+        if self.__version == 1:
+            self.__flags = self.__get_number_or_prop(kwargs['flags'])
         self.__custom0 = self.__get_number_or_prop(kwargs['custom0'])
         self.__custom1 = self.__get_number_or_prop(kwargs['custom1'])
         self.__custom2 = self.__get_number_or_prop(kwargs['custom2'])
-
+        if self.__version == 0:
+            self.__custom3 = self.__get_number_or_prop(kwargs['custom3'])
     def __str__(self):
         sb = []
         sb.append('{key:>20} = {value:d}'.format(key='dt_size',
@@ -107,86 +105,78 @@ class DtEntry(object):
                                                    value=self.__id))
         sb.append('{key:>20} = {value:08x}'.format(key='rev',
                                                    value=self.__rev))
+        if self.__version == 1:
+            sb.append('{key:>20} = {value:08x}'.format(key='flags',
+                                                       value=self.__flags))
         sb.append('{key:>20} = {value:08x}'.format(key='custom[0]',
-                                                   value=self.__flags))
-        sb.append('{key:>20} = {value:08x}'.format(key='custom[1]',
                                                    value=self.__custom0))
-        sb.append('{key:>20} = {value:08x}'.format(key='custom[2]',
+        sb.append('{key:>20} = {value:08x}'.format(key='custom[1]',
                                                    value=self.__custom1))
-        sb.append('{key:>20} = {value:08x}'.format(key='custom[3]',
+        sb.append('{key:>20} = {value:08x}'.format(key='custom[2]',
                                                    value=self.__custom2))
+        if self.__version == 0:
+            sb.append('{key:>20} = {value:08x}'.format(key='custom[3]',
+                                                       value=self.__custom3))
         return '\n'.join(sb)
-
-    def compression_info(self, version):
+    def compression_info(self):
         """CompressionFormat: compression format for DT image file.
-
            Args:
                 version: Version of DTBO header, compression is only
                          supported from version 1.
         """
-        if version is 0:
+        if self.__version == 0:
             return CompressionFormat.NO_COMPRESSION
-        return self.flags & self._COMPRESSION_FORMAT_MASK
-
+        return self.flags & self.COMPRESSION_FORMAT_MASK
     @property
     def dt_file(self):
         """file: File handle to the DT image file."""
         return self.__dt_file
-
     @property
     def size(self):
         """int: size in bytes of the DT image file."""
         return self.__dt_size
-
     @size.setter
     def size(self, value):
         self.__dt_size = value
-
     @property
     def dt_offset(self):
         """int: offset in DTBO file for this DT image."""
         return self.__dt_offset
-
     @dt_offset.setter
     def dt_offset(self, value):
         self.__dt_offset = value
-
     @property
     def image_id(self):
         """int: DT entry _id for this DT image."""
         return self.__id
-
     @property
     def rev(self):
         """int: DT entry _rev for this DT image."""
         return self.__rev
-
     @property
     def flags(self):
         """int: DT entry _flags for this DT image."""
         return self.__flags
-
     @property
     def custom0(self):
         """int: DT entry _custom0 for this DT image."""
         return self.__custom0
-
     @property
     def custom1(self):
         """int: DT entry _custom1 for this DT image."""
         return self.__custom1
-
     @property
     def custom2(self):
         """int: DT entry custom2 for this DT image."""
         return self.__custom2
-
-
+    @property
+    def custom3(self):
+        """int: DT entry custom3 for this DT image."""
+        return self.__custom3
 class Dtbo(object):
     """
     Provides parser, reader, writer for dumping and creating Device Tree Blob
     Overlay (DTBO) images.
-
     Attributes:
         _DTBO_MAGIC: Device tree table header magic.
         _ACPIO_MAGIC: Advanced Configuration and Power Interface table header
@@ -198,7 +188,6 @@ class Dtbo(object):
         _GZIP_COMPRESSION_WBITS: Argument 'wbits' for gzip compression
         _ZLIB_DECOMPRESSION_WBITS: Argument 'wbits' for zlib/gzip compression
     """
-
     _DTBO_MAGIC = 0xd7b7ab1e
     _ACPIO_MAGIC = 0x41435049
     _DT_TABLE_HEADER_SIZE = struct.calcsize('>8I')
@@ -207,10 +196,8 @@ class Dtbo(object):
     _DT_ENTRY_HEADER_INTS = 8
     _GZIP_COMPRESSION_WBITS = 31
     _ZLIB_DECOMPRESSION_WBITS = 47
-
     def _update_dt_table_header(self):
         """Converts header entries into binary data for DTBO header.
-
         Packs the current Device tree table header attribute values in
         metadata buffer.
         """
@@ -219,44 +206,41 @@ class Dtbo(object):
                          self.dt_entry_size, self.dt_entry_count,
                          self.dt_entries_offset, self.page_size,
                          self.version)
-
     def _update_dt_entry_header(self, dt_entry, metadata_offset):
         """Converts each DT entry header entry into binary data for DTBO file.
-
         Packs the current device tree table entry attribute into
         metadata buffer as device tree entry header.
-
         Args:
             dt_entry: DtEntry object for the header to be packed.
             metadata_offset: Offset into metadata buffer to begin writing.
             dtbo_offset: Offset where the DT image file for this dt_entry can
                 be found in the resulting DTBO image.
         """
-        struct.pack_into('>8I', self.__metadata, metadata_offset, dt_entry.size,
-                         dt_entry.dt_offset, dt_entry.image_id, dt_entry.rev,
-                         dt_entry.flags, dt_entry.custom0, dt_entry.custom1,
-                         dt_entry.custom2)
-
+        if self.version == 0:
+            struct.pack_into('>8I', self.__metadata, metadata_offset, dt_entry.size,
+                             dt_entry.dt_offset, dt_entry.image_id, dt_entry.rev,
+                             dt_entry.custom0, dt_entry.custom1, dt_entry.custom2,
+                             dt_entry.custom3)
+        elif self.version == 1:
+            struct.pack_into('>8I', self.__metadata, metadata_offset, dt_entry.size,
+                             dt_entry.dt_offset, dt_entry.image_id, dt_entry.rev,
+                             dt_entry.flags, dt_entry.custom0, dt_entry.custom1,
+                             dt_entry.custom2)
     def _update_metadata(self):
         """Updates the DTBO metadata.
-
         Initialize the internal metadata buffer and fill it with all Device
         Tree table entries and update the DTBO header.
         """
-
-        self.__metadata = array('c', ' ' * self.__metadata_size)
+        self.__metadata = array('b', b' ' * self.__metadata_size)
         metadata_offset = self.header_size
         for dt_entry in self.__dt_entries:
             self._update_dt_entry_header(dt_entry, metadata_offset)
             metadata_offset += self.dt_entry_size
         self._update_dt_table_header()
-
     def _read_dtbo_header(self, buf):
         """Reads DTBO file header into metadata buffer.
-
         Unpack and read the DTBO table header from given buffer. The
         buffer size must exactly be equal to _DT_TABLE_HEADER_SIZE.
-
         Args:
             buf: Bytebuffer read directly from the file of size
                 _DT_TABLE_HEADER_SIZE.
@@ -264,63 +248,57 @@ class Dtbo(object):
         (self.magic, self.total_size, self.header_size,
          self.dt_entry_size, self.dt_entry_count, self.dt_entries_offset,
          self.page_size, self.version) = struct.unpack_from('>8I', buf, 0)
-
         # verify the header
         if self.magic != self._DTBO_MAGIC and self.magic != self._ACPIO_MAGIC:
             raise ValueError('Invalid magic number 0x%x in DTBO/ACPIO file' %
                              (self.magic))
-
         if self.header_size != self._DT_TABLE_HEADER_SIZE:
             raise ValueError('Invalid header size (%d) in DTBO/ACPIO file' %
                              (self.header_size))
-
         if self.dt_entry_size != self._DT_ENTRY_HEADER_SIZE:
             raise ValueError('Invalid DT entry header size (%d) in DTBO/ACPIO file' %
                              (self.dt_entry_size))
-
     def _read_dt_entries_from_metadata(self):
         """Reads individual DT entry headers from metadata buffer.
-
         Unpack and read the DTBO DT entry headers from the internal buffer.
         The buffer size must exactly be equal to _DT_TABLE_HEADER_SIZE +
         (_DT_ENTRY_HEADER_SIZE * dt_entry_count). The method raises exception
         if DT entries have already been set for this object.
         """
-
         if self.__dt_entries:
             raise ValueError('DTBO DT entries can be added only once')
-
-        offset = self.dt_entries_offset / 4
+        offset = self.dt_entries_offset // 4
         params = {}
+        params['version'] = self.version
         params['dt_file'] = None
         for i in range(0, self.dt_entry_count):
             dt_table_entry = self.__metadata[offset:offset + self._DT_ENTRY_HEADER_INTS]
             params['dt_size'] = dt_table_entry[0]
             params['dt_offset'] = dt_table_entry[1]
             for j in range(2, self._DT_ENTRY_HEADER_INTS):
-                params[DtEntry.REQUIRED_KEYS[j + 1]] = str(dt_table_entry[j])
+                required_keys = None
+                if self.version == 0:
+                    required_keys = DtEntry.REQUIRED_KEYS_V0
+                elif self.version == 1:
+                    required_keys = DtEntry.REQUIRED_KEYS_V1
+                params[required_keys[j + 1]] = str(dt_table_entry[j])
             dt_entry = DtEntry(**params)
             self.__dt_entries.append(dt_entry)
             offset += self._DT_ENTRY_HEADER_INTS
-
     def _read_dtbo_image(self):
         """Parse the input file and instantiate this object."""
-
         # First check if we have enough to read the header
         file_size = os.fstat(self.__file.fileno()).st_size
         if file_size < self._DT_TABLE_HEADER_SIZE:
             raise ValueError('Invalid DTBO file')
-
         self.__file.seek(0)
         buf = self.__file.read(self._DT_TABLE_HEADER_SIZE)
         self._read_dtbo_header(buf)
-
         self.__metadata_size = (self.header_size +
                                 self.dt_entry_count * self.dt_entry_size)
         if file_size < self.__metadata_size:
             raise ValueError('Invalid or truncated DTBO file of size %d expected %d' %
                              file_size, self.__metadata_size)
-
         num_ints = (self._DT_TABLE_HEADER_INTS +
                     self.dt_entry_count * self._DT_ENTRY_HEADER_INTS)
         if self.dt_entries_offset > self._DT_TABLE_HEADER_SIZE:
@@ -330,10 +308,8 @@ class Dtbo(object):
         self.__metadata = struct.unpack(format_str,
                                         self.__file.read(self.__metadata_size))
         self._read_dt_entries_from_metadata()
-
     def _find_dt_entry_with_same_file(self, dt_entry):
         """Finds DT Entry that has identical backing DT file.
-
         Args:
             dt_entry: DtEntry object whose 'dtfile' we find for existence in the
                 current 'dt_entries'.
@@ -341,28 +317,23 @@ class Dtbo(object):
             If a match by file path is found, the corresponding DtEntry object
             from internal list is returned. If not, 'None' is returned.
         """
-
         dt_entry_path = os.path.realpath(dt_entry.dt_file.name)
         for entry in self.__dt_entries:
             entry_path = os.path.realpath(entry.dt_file.name)
             if entry_path == dt_entry_path:
                 return entry
         return None
-
     def __init__(self, file_handle, dt_type='dtb', page_size=None, version=0):
         """Constructor for Dtbo Object
-
         Args:
             file_handle: The Dtbo File handle corresponding to this object.
                 The file handle can be used to write to (in case of 'create')
                 or read from (in case of 'dump')
         """
-
         self.__file = file_handle
         self.__dt_entries = []
         self.__metadata = None
         self.__metadata_size = 0
-
         # if page_size is given, assume the object is being instantiated to
         # create a DTBO file
         if page_size:
@@ -380,7 +351,6 @@ class Dtbo(object):
             self.__metadata_size = self._DT_TABLE_HEADER_SIZE
         else:
             self._read_dtbo_image()
-
     def __str__(self):
         sb = []
         sb.append('dt_table_header:')
@@ -399,22 +369,17 @@ class Dtbo(object):
             sb.append(str(dt_entry))
             count = count + 1
         return '\n'.join(sb)
-
     @property
     def dt_entries(self):
         """Returns a list of DtEntry objects found in DTBO file."""
         return self.__dt_entries
-
     def compress_dt_entry(self, compression_format, dt_entry_file):
         """Compresses a DT entry.
-
         Args:
             compression_format: Compression format for DT Entry
             dt_entry_file: File handle to read DT entry from.
-
         Returns:
             Compressed DT entry and its length.
-
         Raises:
             ValueError if unrecognized compression format is found.
         """
@@ -426,10 +391,8 @@ class Dtbo(object):
             CompressionFormat.ZLIB_COMPRESSION: compress_zlib,
             CompressionFormat.GZIP_COMPRESSION: compress_gzip,
         }
-
         if compression_format not in compression_obj_dict:
             ValueError("Bad compression format %d" % compression_format)
-
         if compression_format is CompressionFormat.NO_COMPRESSION:
             dt_entry = dt_entry_file.read()
         else:
@@ -438,41 +401,32 @@ class Dtbo(object):
             dt_entry = compression_object.compress(dt_entry_file.read())
             dt_entry += compression_object.flush()
         return dt_entry, len(dt_entry)
-
     def add_dt_entries(self, dt_entries):
         """Adds DT image files to the DTBO object.
-
         Adds a list of Dtentry Objects to the DTBO image. The changes are not
         committed to the output file until commit() is called.
-
         Args:
             dt_entries: List of DtEntry object to be added.
-
         Returns:
             A buffer containing all DT entries.
-
         Raises:
             ValueError: if the list of DT entries is empty or if a list of DT entries
                 has already been added to the DTBO.
         """
         if not dt_entries:
             raise ValueError('Attempted to add empty list of DT entries')
-
         if self.__dt_entries:
             raise ValueError('DTBO DT entries can be added only once')
-
         dt_entry_count = len(dt_entries)
         dt_offset = (self.header_size +
                      dt_entry_count * self.dt_entry_size)
-
-        dt_entry_buf = ""
+        dt_entry_buf = b""
         for dt_entry in dt_entries:
             if not isinstance(dt_entry, DtEntry):
                 raise ValueError('Adding invalid DT entry object to DTBO')
             entry = self._find_dt_entry_with_same_file(dt_entry)
-            dt_entry_compression_info = dt_entry.compression_info(self.version)
-            if entry and (entry.compression_info(self.version)
-                          == dt_entry_compression_info):
+            dt_entry_compression_info = dt_entry.compression_info()
+            if entry and (entry.compression_info() == dt_entry_compression_info):
                 dt_entry.dt_offset = entry.dt_offset
                 dt_entry.size = entry.size
             else:
@@ -486,31 +440,25 @@ class Dtbo(object):
             self.dt_entry_count += 1
             self.__metadata_size += self.dt_entry_size
             self.total_size += self.dt_entry_size
-
         return dt_entry_buf
-
     def extract_dt_file(self, idx, fout, decompress):
         """Extract DT Image files embedded in the DTBO file.
-
         Extracts Device Tree blob image file at given index into a file handle.
-
         Args:
             idx: Index of the DT entry in the DTBO file.
             fout: File handle where the DTB at index idx to be extracted into.
             decompress: If a DT entry is compressed, decompress it before writing
                 it to the file handle.
-
         Raises:
             ValueError: if invalid DT entry index or compression format is detected.
         """
         if idx > self.dt_entry_count:
             raise ValueError('Invalid index %d of DtEntry' % idx)
-
         size = self.dt_entries[idx].size
         offset = self.dt_entries[idx].dt_offset
         self.__file.seek(offset, 0)
         fout.seek(0)
-        compression_format = self.dt_entries[idx].compression_info(self.version)
+        compression_format = self.dt_entries[idx].compression_info()
         if decompress and compression_format:
             if (compression_format == CompressionFormat.ZLIB_COMPRESSION or
                 compression_format == CompressionFormat.GZIP_COMPRESSION):
@@ -519,47 +467,35 @@ class Dtbo(object):
                 raise ValueError("Unknown compression format detected")
         else:
             fout.write(self.__file.read(size))
-
     def commit(self, dt_entry_buf):
         """Write out staged changes to the DTBO object to create a DTBO file.
-
         Writes a fully instantiated Dtbo Object into the output file using the
         file handle present in '_file'. No checks are performed on the object
         except for existence of output file handle on the object before writing
         out the file.
-
         Args:
             dt_entry_buf: Buffer containing all DT entries.
         """
         if not self.__file:
             raise ValueError('No file given to write to.')
-
         if not self.__dt_entries:
             raise ValueError('No DT image files to embed into DTBO image given.')
-
         self._update_metadata()
-
         self.__file.seek(0)
         self.__file.write(self.__metadata)
         self.__file.write(dt_entry_buf)
         self.__file.flush()
-
-
 def parse_dt_entry(global_args, arglist):
     """Parse arguments for single DT entry file.
-
     Parses command line arguments for single DT image file while
     creating a Device tree blob overlay (DTBO).
-
     Args:
         global_args: Dtbo object containing global default values
             for DtEntry attributes.
         arglist: Command line argument list for this DtEntry.
-
     Returns:
         A Namespace object containing all values to instantiate DtEntry object.
     """
-
     parser = argparse.ArgumentParser(add_help=False)
     parser.add_argument('dt_file', nargs='?',
                         type=argparse.FileType('rb'),
@@ -580,21 +516,19 @@ def parse_dt_entry(global_args, arglist):
     parser.add_argument('--custom2', type=str, dest='custom2',
                         action='store',
                         default=global_args.global_custom2)
+    parser.add_argument('--custom3', type=str, dest='custom3',
+                        action='store',
+                        default=global_args.global_custom3)
     return parser.parse_args(arglist)
-
-
 def parse_dt_entries(global_args, arg_list):
     """Parse all DT entries from command line.
-
     Parse all DT image files and their corresponding attribute from
     command line
-
     Args:
         global_args: Argument containing default global values for _id,
             _rev and customX.
         arg_list: The remainder of the command line after global options
             DTBO creation have been parsed.
-
     Returns:
         A List of DtEntry objects created after parsing the command line
         given in argument.
@@ -607,12 +541,10 @@ def parse_dt_entries(global_args, arg_list):
         if not arg.startswith("--"):
             img_file_idx.append(idx)
         idx = idx + 1
-
     if not img_file_idx:
         raise ValueError('Input DT images must be provided')
-
     total_images = len(img_file_idx)
-    for idx in xrange(total_images):
+    for idx in range(total_images):
         start_idx = img_file_idx[idx]
         if idx == total_images - 1:
             argv = arg_list[start_idx:]
@@ -621,15 +553,13 @@ def parse_dt_entries(global_args, arg_list):
             argv = arg_list[start_idx:end_idx]
         args = parse_dt_entry(global_args, argv)
         params = vars(args)
+        params['version'] = global_args.version
         params['dt_offset'] = 0
         params['dt_size'] = os.fstat(params['dt_file'].fileno()).st_size
         dt_entries.append(DtEntry(**params))
-
     return dt_entries
-
 def parse_config_option(line, is_global, dt_keys, global_key_types):
     """Parses a single line from the configuration file.
-
     Args:
         line: String containing the key=value line from the file.
         is_global: Boolean indicating if we should parse global or DT entry
@@ -639,27 +569,21 @@ def parse_config_option(line, is_global, dt_keys, global_key_types):
         global_key_types: A dict of global options and their corresponding types. It
             contains all exclusive valid global option strings in configuration
             file that are not repeated in dt entry options.
-
     Returns:
         Returns a tuple for parsed key and value for the option. Also, checks
         the key to make sure its valid.
     """
-
     if line.find('=') == -1:
         raise ValueError('Invalid line (%s) in configuration file' % line)
-
     key, value = (x.strip() for x in line.split('='))
     if is_global and key in global_key_types:
         if global_key_types[key] is int:
             value = int(value)
     elif key not in dt_keys:
         raise ValueError('Invalid option (%s) in configuration file' % key)
-
     return key, value
-
 def parse_config_file(fin, dt_keys, global_key_types):
     """Parses the configuration file for creating DTBO image.
-
     Args:
         fin: File handle for configuration file
         is_global: Boolean indicating if we should parse global or DT entry
@@ -669,7 +593,6 @@ def parse_config_file(fin, dt_keys, global_key_types):
         global_key_types: A dict of global options and their corresponding types. It
             contains all exclusive valid global option strings in configuration
             file that are not repeated in dt entry options.
-
     Returns:
         global_args, dt_args: Tuple of a dictionary with global arguments
         and a list of dictionaries for all DT entry specific arguments the
@@ -683,13 +606,11 @@ def parse_config_file(fin, dt_keys, global_key_types):
                   'rev' : <value2> ...}, ...
                 ]
     """
-
     # set all global defaults
     global_args = dict((k, '0') for k in dt_keys)
     global_args['dt_type'] = 'dtb'
     global_args['page_size'] = 2048
     global_args['version'] = 0
-
     dt_args = []
     found_dt_entry = False
     count = -1
@@ -714,24 +635,19 @@ def parse_config_file(fin, dt_keys, global_key_types):
             dt_args.append({})
             dt_args[-1]['filename'] = line.strip()
     return global_args, dt_args
-
 def parse_create_args(arg_list):
     """Parse command line arguments for 'create' sub-command.
-
     Args:
         arg_list: All command line arguments except the outfile file name.
-
     Returns:
         The list of remainder of the command line arguments after parsing
         for 'create'.
     """
-
     image_arg_index = 0
     for arg in arg_list:
         if not arg.startswith("--"):
             break
         image_arg_index = image_arg_index + 1
-
     argv = arg_list[0:image_arg_index]
     remainder = arg_list[image_arg_index:]
     parser = argparse.ArgumentParser(prog='create', add_help=False)
@@ -753,57 +669,49 @@ def parse_create_args(arg_list):
                         action='store', default='0')
     parser.add_argument('--custom2', type=str, dest='global_custom2',
                         action='store', default='0')
+    parser.add_argument('--custom3', type=str, dest='global_custom3',
+                        action='store', default='0')
     args = parser.parse_args(argv)
     return args, remainder
-
 def parse_dump_cmd_args(arglist):
     """Parse command line arguments for 'dump' sub-command.
-
     Args:
         arglist: List of all command line arguments including the outfile
             file name if exists.
-
     Returns:
         A namespace object of parsed arguments.
     """
-
     parser = argparse.ArgumentParser(prog='dump')
     parser.add_argument('--output', '-o', nargs='?',
-                        type=argparse.FileType('wb'),
+                        type=argparse.FileType('w'),
                         dest='outfile',
                         default=stdout)
     parser.add_argument('--dtb', '-b', nargs='?', type=str,
                         dest='dtfilename')
     parser.add_argument('--decompress', action='store_true', dest='decompress')
     return parser.parse_args(arglist)
-
 def parse_config_create_cmd_args(arglist):
     """Parse command line arguments for 'cfg_create subcommand.
-
     Args:
         arglist: A list of all command line arguments including the
             mandatory input configuration file name.
-
     Returns:
         A Namespace object of parsed arguments.
     """
     parser = argparse.ArgumentParser(prog='cfg_create')
     parser.add_argument('conf_file', nargs='?',
-                        type=argparse.FileType('rb'),
+                        type=argparse.FileType('r'),
                         default=None)
     cwd = os.getcwd()
     parser.add_argument('--dtb-dir', '-d', nargs='?', type=str,
                         dest='dtbdir', default=cwd)
     return parser.parse_args(arglist)
-
 def create_dtbo_image(fout, argv):
     """Create Device Tree Blob Overlay image using provided arguments.
-
     Args:
         fout: Output file handle to write to.
         argv: list of command line arguments.
     """
-
     global_args, remainder = parse_create_args(argv)
     if not remainder:
         raise ValueError('List of dtimages to add to DTBO not provided')
@@ -812,14 +720,11 @@ def create_dtbo_image(fout, argv):
     dt_entry_buf = dtbo.add_dt_entries(dt_entries)
     dtbo.commit(dt_entry_buf)
     fout.close()
-
 def dump_dtbo_image(fin, argv):
     """Dump DTBO file.
-
     Dump Device Tree Blob Overlay metadata as output and the device
     tree image files embedded in the DTBO image into file(s) provided
     as arguments
-
     Args:
         fin: Input DTBO image files.
         argv: list of command line arguments.
@@ -833,10 +738,8 @@ def dump_dtbo_image(fin, argv):
                 dtbo.extract_dt_file(idx, fout, args.decompress)
     args.outfile.write(str(dtbo) + '\n')
     args.outfile.close()
-
 def create_dtbo_image_from_config(fout, argv):
     """Create DTBO file from a configuration file.
-
     Args:
         fout: Output file handle to write to.
         argv: list of command line arguments.
@@ -844,16 +747,20 @@ def create_dtbo_image_from_config(fout, argv):
     args = parse_config_create_cmd_args(argv)
     if not args.conf_file:
         raise ValueError('Configuration file must be provided')
-
-    _DT_KEYS = ('id', 'rev', 'flags', 'custom0', 'custom1', 'custom2')
+    _DT_KEYS = ('id', 'rev', 'flags', 'custom0', 'custom1', 'custom2', 'custom3')
     _GLOBAL_KEY_TYPES = {'dt_type': str, 'page_size': int, 'version': int}
-
     global_args, dt_args = parse_config_file(args.conf_file,
                                              _DT_KEYS, _GLOBAL_KEY_TYPES)
+    version = global_args['version']
     params = {}
+    params['version'] = version
     dt_entries = []
     for dt_arg in dt_args:
-        filepath = args.dtbdir + os.sep + dt_arg['filename']
+        filepath = dt_arg['filename']
+        if not os.path.isabs(filepath):
+            for root, dirnames, filenames in os.walk(args.dtbdir):
+                for filename in fnmatch.filter(filenames, os.path.basename(filepath)):
+                    filepath = os.path.join(root, filename)
         params['dt_file'] = open(filepath, 'rb')
         params['dt_offset'] = 0
         params['dt_size'] = os.fstat(params['dt_file'].fileno()).st_size
@@ -863,16 +770,13 @@ def create_dtbo_image_from_config(fout, argv):
             else:
                 params[key] = dt_arg[key]
         dt_entries.append(DtEntry(**params))
-
     # Create and write DTBO file
-    dtbo = Dtbo(fout, global_args['dt_type'], global_args['page_size'], global_args['version'])
+    dtbo = Dtbo(fout, global_args['dt_type'], global_args['page_size'], version)
     dt_entry_buf = dtbo.add_dt_entries(dt_entries)
     dtbo.commit(dt_entry_buf)
     fout.close()
-
 def print_default_usage(progname):
     """Prints program's default help string.
-
     Args:
         progname: This program's name.
     """
@@ -882,10 +786,8 @@ def print_default_usage(progname):
     sb.append('    commands:')
     sb.append('      help, dump, create, cfg_create')
     print('\n'.join(sb))
-
 def print_dump_usage(progname):
     """Prints usage for 'dump' sub-command.
-
     Args:
         progname: This program's name.
     """
@@ -897,10 +799,8 @@ def print_dump_usage(progname):
     sb.append('      -b, --dtb <filename>     Dump dtb/dtbo files from image.')
     sb.append('                               Will output to <filename>.0, <filename>.1, etc.')
     print('\n'.join(sb))
-
 def print_create_usage(progname):
     """Prints usage for 'create' subcommand.
-
     Args:
         progname: This program's name.
     """
@@ -916,16 +816,14 @@ def print_create_usage(progname):
     sb.append('      --custom0=<number>')
     sb.append('      --custom1=<number>')
     sb.append('      --custom2=<number>\n')
-
+    sb.append('      --custom3=<number>\n')
     sb.append('      The value could be a number or a DT node path.')
     sb.append('      <number> could be a 32-bits digit or hex value, ex. 68000, 0x6800.')
     sb.append('      <path> format is <full_node_path>:<property_name>, ex. /board/:id,')
     sb.append('      will read the value in given FTB file with the path.')
     print('\n'.join(sb))
-
 def print_cfg_create_usage(progname):
     """Prints usage for 'cfg_create' sub-command.
-
     Args:
         progname: This program's name.
     """
@@ -935,10 +833,8 @@ def print_cfg_create_usage(progname):
     sb.append('      -d, --dtb-dir <dir>      The path to load dtb files.')
     sb.append('                               Default is load from the current path.')
     print('\n'.join(sb))
-
 def print_usage(cmd, _):
     """Prints usage for this program.
-
     Args:
         cmd: The string sub-command for which help (usage) is requested.
     """
@@ -946,58 +842,45 @@ def print_usage(cmd, _):
     if not cmd:
         print_default_usage(prog_name)
         return
-
     HelpCommand = namedtuple('HelpCommand', 'help_cmd, help_func')
     help_commands = (HelpCommand('dump', print_dump_usage),
                      HelpCommand('create', print_create_usage),
                      HelpCommand('cfg_create', print_cfg_create_usage),
                      )
-
     if cmd == 'all':
         print_default_usage(prog_name)
-
     for help_cmd, help_func in help_commands:
         if cmd == 'all' or cmd == help_cmd:
             help_func(prog_name)
             if cmd != 'all':
                 return
-
     print('Unsupported help command: %s' % cmd, end='\n\n')
     print_default_usage(prog_name)
     return
-
 def main():
     """Main entry point for mkdtboimg."""
-
     parser = argparse.ArgumentParser(prog='mkdtboimg.py')
-
     subparser = parser.add_subparsers(title='subcommand',
                                       description='Valid subcommands')
-
     create_parser = subparser.add_parser('create', add_help=False)
     create_parser.add_argument('argfile', nargs='?',
                                action='store', help='Output File',
                                type=argparse.FileType('wb'))
     create_parser.set_defaults(func=create_dtbo_image)
-
     config_parser = subparser.add_parser('cfg_create', add_help=False)
     config_parser.add_argument('argfile', nargs='?',
                                action='store',
                                type=argparse.FileType('wb'))
     config_parser.set_defaults(func=create_dtbo_image_from_config)
-
     dump_parser = subparser.add_parser('dump', add_help=False)
     dump_parser.add_argument('argfile', nargs='?',
                              action='store',
                              type=argparse.FileType('rb'))
     dump_parser.set_defaults(func=dump_dtbo_image)
-
     help_parser = subparser.add_parser('help', add_help=False)
     help_parser.add_argument('argfile', nargs='?', action='store')
     help_parser.set_defaults(func=print_usage)
-
     (subcmd, subcmd_args) = parser.parse_known_args()
     subcmd.func(subcmd.argfile, subcmd_args)
-
 if __name__ == '__main__':
     main()
-- 
2.45.2
```
