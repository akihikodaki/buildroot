################################################################################
#
# python-pyqt5
#
################################################################################

PYTHON_PYQT5_VERSION = 5.6
PYTHON_PYQT5_SOURCE = PyQt5_gpl-$(PYTHON_PYQT5_VERSION).tar.gz
PYTHON_PYQT5_SITE = http://downloads.sourceforge.net/project/pyqt/PyQt5/PyQt-$(PYTHON_PYQT5_VERSION)
PYTHON_PYQT5_LICENSE = GPLv2 or GPLv3
PYTHON_PYQT5_LICENSE_FILES = LICENSE.GPL2 LICENSE.GPL3

PYTHON_PYQT5_DEPENDENCIES = python-sip host-python-sip qt5base

ifeq ($(BR2_PACKAGE_QT5CONNECTIVITY),y)
PYTHON_PYQT5_DEPENDENCIES += qt5connectivity
endif

ifeq ($(BR2_PACKAGE_QT5DECLARATIVE),y)
PYTHON_PYQT5_DEPENDENCIES += qt5declarative
endif

ifeq ($(BR2_PACKAGE_QT5IMAGEFORMATS),y)
PYTHON_PYQT5_DEPENDENCIES += qt5imageformats
endif

ifeq ($(BR2_PACKAGE_QT5MULTIMEDIA),y)
PYTHON_PYQT5_DEPENDENCIES += qt5multimedia
endif

ifeq ($(BR2_PACKAGE_QT5SENSORS),y)
PYTHON_PYQT5_DEPENDENCIES += qt5sensors
endif

ifeq ($(BR2_PACKAGE_QT5SERIALPORT),y)
PYTHON_PYQT5_DEPENDENCIES += qt5serialport
endif

ifeq ($(BR2_PACKAGE_QT5SVG),y)
PYTHON_PYQT5_DEPENDENCIES += qt5svg
endif

ifeq ($(BR2_PACKAGE_QT5WEBCHANNEL),y)
PYTHON_PYQT5_DEPENDENCIES += qt5webchannel
endif

ifeq ($(BR2_PACKAGE_QT5WEBENGINE),y)
PYTHON_PYQT5_DEPENDENCIES += qt5webengine
endif

ifeq ($(BR2_PACKAGE_QT5WEBKIT),y)
PYTHON_PYQT5_DEPENDENCIES += qt5webkit
endif

ifeq ($(BR2_PACKAGE_QT5WEBSOCKETS),y)
PYTHON_PYQT5_DEPENDENCIES += qt5websockets
endif

ifeq ($(BR2_PACKAGE_QT5X11EXTRAS),y)
PYTHON_PYQT5_DEPENDENCIES += qt5x11extras
endif

ifeq ($(BR2_PACKAGE_QT5XMLPATTERNS),y)
PYTHON_PYQT5_DEPENDENCIES += qt5xmlpatterns
endif

ifeq ($(BR2_PACKAGE_PYTHON),y)
PYTHON_PYQT5_PYTHON_DIR = python$(PYTHON_VERSION_MAJOR)
else ifeq ($(BR2_PACKAGE_PYTHON3),y)
PYTHON_PYQT5_PYTHON_DIR = python$(PYTHON3_VERSION_MAJOR)
PYTHON_PYQT5_RM_PORT_BASE = port_v2
endif

PYTHON_PYQT5_INCLUDE_DIR = usr/include/$(PYTHON_PYQT5_PYTHON_DIR)m
PYTHON_PYQT5_LIB_DIR = usr/lib/$(PYTHON_PYQT5_PYTHON_DIR)

ifeq ($(BR2_PACKAGE_QT_EMBEDDED),y)
PYTHON_PYQT5_QTFLAVOR = WS_QWS
else
PYTHON_PYQT5_QTFLAVOR = WS_X11
endif

# Turn off features that aren't available in QWS and current qt
# configuration.
PYTHON_PYQT5_CONFIGURATION_DISABLE_FEATURES = \
	PyQt_Accessibility PyQt_SessionManager PyQt_RawFont

ifeq ($(BR2_PACKAGE_QT_OPENSSL),)
PYTHON_PYQT5_CONFIGURATION_DISABLE_FEATURES += PyQt_SSL
endif

ifeq ($(BR2_PACKAGE_QT5BASE_OPENGL),)
PYTHON_PYQT5_CONFIGURATION_DISABLE_FEATURES += PyQt_OpenGL
else ifeq ($(BR2_PACKAGE_QT5BASE_OPENGL_ES2),y)
# Yes, this looks a bit weird: when OpenGL ES is available, we have to
# disable the feature that consists in having Desktop OpenGL support.
PYTHON_PYQT5_CONFIGURATION_DISABLE_FEATURES += PyQt_Desktop_OpenGL
endif

define PYTHON_PYQT5_CONFIGURATION
	echo $(1) >> $(2)/configuration
endef

# Since we can't run generate configuration by running qtdetail on target device
# we must generate the configuration.
define PYTHON_PYQT5_GENERATE_CONFIGURATION
	$(RM) -f $(1)/configuration
	$(call PYTHON_PYQT5_CONFIGURATION,py_inc_dir = $(STAGING_DIR)/$(PYTHON_PYQT5_INCLUDE_DIR),$(1))
	$(call PYTHON_PYQT5_CONFIGURATION,qt_shared = True,$(1))
	$(call PYTHON_PYQT5_CONFIGURATION,pyqt_disabled_features = $(PYTHON_PYQT5_CONFIGURATION_DISABLE_FEATURES),$(1))
	$(call PYTHON_PYQT5_CONFIGURATION,[Qt 5.5.1],$(1))
endef

PYTHON_PYQT5_CONF_OPTS = \
	--bindir $(TARGET_DIR)/usr/bin \
	--destdir $(TARGET_DIR)/$(PYTHON_PYQT5_LIB_DIR)/site-packages \
	--configuration $(@D)/configuration \
	--qmake $(HOST_DIR)/usr/bin/qmake \
	--sysroot $(STAGING_DIR)/usr \
	-w --confirm-license \
	--no-designer-plugin \
	--no-docstrings \
	--no-sip-files \
	--qt-flavor=$(PYTHON_PYQT5_QTFLAVOR)

# The VendorID related information is only needed for Python 2.x, not
# Python 3.x.
ifeq ($(BR2_PACKAGE_PYTHON),y)
PYTHON_PYQT5_CONF_OPTS += \
	--vendorid-incdir $(STAGING_DIR)/$(PYTHON_PYQT5_INCLUDE_DIR)  \
	--vendorid-libdir $(STAGING_DIR)/$(PYTHON_PYQT5_LIB_DIR)/config
endif

define PYTHON_PYQT5_CONFIGURE_CMDS
	$(call PYTHON_PYQT5_GENERATE_CONFIGURATION,$(@D))
	(cd $(@D); \
		$(TARGET_MAKE_ENV) \
		$(TARGET_CONFIGURE_OPTS) \
		$(HOST_DIR)/usr/bin/python configure.py \
			$(PYTHON_PYQT5_CONF_OPTS) \
	)
endef

define PYTHON_PYQT5_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D)
endef

# __init__.py is needed to import PyQt5
# __init__.pyc is needed if BR2_PACKAGE_PYTHON_PYC_ONLY is set
define PYTHON_PYQT5_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D) install
	touch $(TARGET_DIR)/$(PYTHON_PYQT5_LIB_DIR)/site-packages/PyQt5/__init__.py
	$(RM) -rf $(TARGET_DIR)/$(PYTHON_PYQT5_LIB_DIR)/site-packages/PyQt5/uic/$(PYTHON_PYQT5_RM_PORT_BASE)
	PYTHONPATH="$(PYTHON_PATH)" \
		$(HOST_DIR)/usr/bin/python -c "import compileall; \
		compileall.compile_dir('$(TARGET_DIR)/$(PYTHON_PYQT5_LIB_DIR)/site-packages/PyQt5')"
endef

$(eval $(generic-package))
