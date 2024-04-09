LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := su_kernel
LOCAL_SRC_FILES := su.c
include $(BUILD_EXECUTABLE)
