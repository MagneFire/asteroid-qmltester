cmake_minimum_required(VERSION 3.6.0)

project(asteroid-qmltester
	VERSION 0.0.1
	DESCRIPTION "Default qmltester app for AsteroidOS")

find_package(ECM REQUIRED NO_MODULE)
find_package(AsteroidApp REQUIRED)

set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${ASTEROID_MODULE_PATH})

include(FeatureSummary)
include(GNUInstallDirs)
include(ECMQMLModules)
include(AsteroidCMakeSettings)
include(AsteroidTranslations)

ecm_find_qmlmodule(Nemo.KeepAlive 1.1)

add_subdirectory(src)

generate_desktop(${CMAKE_SOURCE_DIR} asteroid-qmltester)

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)
