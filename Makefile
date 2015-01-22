ARCHS = arm64 armv7

include theos/makefiles/common.mk

TWEAK_NAME = SpotCall
SpotCall_FILES = Tweak.xm
SpotCall_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
