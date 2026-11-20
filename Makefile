TARGET = iphone:clang:latest:15.0
ARCHS = arm64
INSTALL_TARGET_PROCESSES = FC Mobile

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FCMMenu
FCMMenu_FILES = Tweak.xm Menu.mm
FCMMenu_CFLAGS = -fobjc-arc
FCMMenu_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
