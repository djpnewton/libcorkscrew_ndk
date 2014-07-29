# Copyright (C) 2011 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

LOCAL_PATH:= $(call my-dir)

generic_src_files := \
	backtrace.c \
	backtrace-helper.c \
	demangle.c \
	map_info.c \
	ptrace.c \
	symbol_table.c

arm_src_files := \
	arch-arm/backtrace-arm.c \
	arch-arm/ptrace-arm.c

x86_src_files := \
	arch-x86/backtrace-x86.c \
	arch-x86/ptrace-x86.c

include $(CLEAR_VARS)

LOCAL_SRC_FILES := $(generic_src_files)

ifeq ($(TARGET_ARCH),arm)
LOCAL_SRC_FILES += $(arm_src_files)
LOCAL_CFLAGS += -DCORKSCREW_HAVE_ARCH
endif
ifeq ($(TARGET_ARCH),x86)
LOCAL_SRC_FILES += $(x86_src_files)
LOCAL_CFLAGS += -DCORKSCREW_HAVE_ARCH
endif
ifeq ($(TARGET_ARCH),mips)
LOCAL_SRC_FILES += \
	arch-mips/backtrace-mips.c \
	arch-mips/ptrace-mips.c
LOCAL_CFLAGS += -DCORKSCREW_HAVE_ARCH
endif

LOCAL_SHARED_LIBRARIES += libdl libcutils liblog libgccdemangle

LOCAL_CFLAGS += -std=gnu99 -Werror
LOCAL_MODULE := libcorkscrew
LOCAL_MODULE_TAGS := optional

# install variables
prefix = /usr/local
bindir = $(prefix)/bin
libdir = $(prefix)/lib
incdir = $(prefix)/include

#TODO!! SYSTEM specific stuff here!!
NDK_TOOLCHAIN = /opt/android-ndk-r9b/toolchains/arm-linux-androideabi-4.8/prebuilt/linux-x86_64
TOOLCHAIN_PREFIX = $(NDK_TOOLCHAIN)/bin/arm-linux-androideabi-
prefix = $(NDK_TOOLCHAIN)/user
SYSROOT = /opt/android-ndk-r9b/platforms/android-18/arch-arm
NDK_GCCINC = $(NDK_TOOLCHAIN)/lib/gcc/arm-linux-androideabi/4.8/include

AR = $(TOOLCHAIN_PREFIX)ar
CC = $(TOOLCHAIN_PREFIX)gcc
CXX = $(TOOLCHAIN_PREFIX)g++
CFLAGS += -g -O0 -fPIC -fvisibility=hidden

CFLAGS += --sysroot=$(SYSROOT)
CFLAGS +=  -I. #-I$(NDK_TOOLCHAIN)/user/include #-I$(NDK_GCCINC)
CFLAGS += -L$(NDK_TOOLCHAIN)/user/lib
CFLAGS += $(LOCAL_CFLAGS)

OBJ = $(LOCAL_SRC_FILES:.c=.o)

%.o: %.c
	$(CC) $(CFLAGS) -o $@ -c $^

$(LOCAL_MODULE).a: $(OBJ)
	$(AR) rcs $@ $^

$(LOCAL_MODULE).so: $(OBJ)
	$(CC) $(CFLAGS) -o $@ $^ $(SO_LIBS) -shared -Wl,--exclude-libs=ALL

install: $(LOCAL_MODULE).a $(LOCAL_MODULE).so
	mkdir -p $(libdir)
	mkdir -p $(incdir)
	cp $(LOCAL_MODULE).a $(libdir)
	cp $(LOCAL_MODULE).so $(libdir)
	cp -r corkscrew $(incdir)

clean:
	rm -f *.o $(LOCAL_MODULE).a $(LOCAL_MODULE).so

.PHONY: clean
