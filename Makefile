ARCHS = arm64 arm64e
export THEOS_PACKAGE_SCHEME = rootless
TARGET = iphone:clang:latest:15.0
INSTALL_TARGET_PROCESSES = Aweme

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = KCMenuDemo

KCMenuDemo_FILES = Tweak.xm SettingsViewController.m
KCMenuDemo_CFLAGS = -fobjc-arc -ISources
KCMenuDemo_FRAMEWORKS = UIKit Foundation
KCMenuDemo_LDFLAGS = -ObjC

include $(THEOS_MAKE_PATH)/tweak.mk
