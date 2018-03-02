################################################################################
#
# spapcast
#
################################################################################

SNAPCAST_VERSION = 075bff68
SNAPCAST_SITE = $(call github,badaix,snapcast,$(SNAPCAST_VERSION))
SNAPCAST_DEPENDENCIES = libogg alsa-lib avahi # libstdcpp libatomic libflac libvorbisidec
SNAPCAST_LICENSE = GPL-3.0+
SNAPCAST_LICENSE_FILES = LICENSE


ifeq ($(BR2_PACKAGE_SNAPCAST_CLIENT),y)
define SNAPCLIENT_INSTALL_CONFIG
	mkdir -p $(TARGET_DIR)/etc/default
	$(INSTALL) -m 0755 -D $(@D)/client/debian/snapclient.default $(TARGET_DIR)/etc/default/snapclient
endef

define SNAPCLIENT_INSTALL_INIT_SYSV
	$(SNAPCLIENT_INSTALL_CONFIG)
	$(INSTALL) -m 0755 -D $(SNAPCAST_PKGDIR)/S99snapclient $(TARGET_DIR)/etc/init.d/S99snapclient
endef

define SNAPCLIENT_INSTALL_INIT_SYSTEMD
	$(SNAPCLIENT_INSTALL_CONFIG)
	$(INSTALL) -D -m 0644 $(@D)/client/debian/snapclient.service \
		$(TARGET_DIR)/usr/lib/systemd/system/snapclient.service

	mkdir -p $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants

	ln -fs ../../../../usr/lib/systemd/system/snapclient.service \
		$(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/snapclient.service
endef
endif


ifeq ($(BR2_PACKAGE_SNAPCAST_SERVER),y)
define SNAPSERVER_INSTALL_CONFIG
	mkdir -p $(TARGET_DIR)/etc/default
	$(INSTALL) -m 0755 -D $(@D)/server/debian/snapserver.default $(TARGET_DIR)/etc/default/snapserver
endef

define SNAPSERVER_INSTALL_INIT_SYSV
	$(SNAPSERVER_INSTALL_CONFIG)
	$(INSTALL) -m 0755 -D $(SNAPCAST_PKGDIR)/S99snapserver $(TARGET_DIR)/etc/init.d/S99snapserver
endef

define SNAPSERVER_INSTALL_INIT_SYSTEMD
	$(SNAPSERVER_INSTALL_CONFIG)
	$(INSTALL) -D -m 0644 $(@D)/server/debian/snapserver.service \
		$(TARGET_DIR)/usr/lib/systemd/system/snapserver.service

	mkdir -p $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants

	ln -fs ../../../../usr/lib/systemd/system/snapserver.service \
		$(TARGET_DIR)/etc/systemd/system/multi-user.target.wants/snapserver.service
endef
endif


define SNAPCAST_INSTALL_INIT_SYSTEMD
	$(SNAPCLIENT_INSTALL_INIT_SYSTEMD)
	$(SNAPSERVER_INSTALL_INIT_SYSTEMD)
endef

define SNAPCAST_INSTALL_INIT_SYSV
	$(SNAPCLIENT_INSTALL_INIT_SYSV)
	$(SNAPSERVER_INSTALL_INIT_SYSV)
endef


$(eval $(cmake-package))
