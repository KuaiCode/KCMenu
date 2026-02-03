ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:15.0
PACKAGE_FORMAT = ipa

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = KCMenuTest

KCMenuTest_FILES = main.m AppDelegate.m MainViewController.m ../SettingsViewController.m
KCMenuTest_CFLAGS = -fobjc-arc
KCMenuTest_FRAMEWORKS = UIKit Foundation QuartzCore
KCMenuTest_LDFLAGS = -ObjC
KCMenuTest_CODESIGN_FLAGS = -S

include $(THEOS_MAKE_PATH)/application.mk
