cmake_minimum_required(VERSION 3.20)

project(asteroid-qmltester
	VERSION 1.0.0
	DESCRIPTION "Default qmltester app for AsteroidOS")

find_package(ECM REQUIRED NO_MODULE)
find_package(AsteroidApp6 REQUIRED)

set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${ASTEROID_MODULE_PATH})

include(FeatureSummary)
include(GNUInstallDirs)
include(ECMFindQmlModule)
include(Asteroid6CMakeSettings)
include(Asteroid6Translations)

ecm_find_qmlmodule(Nemo.KeepAlive 1.1)

add_subdirectory(src)

generate_desktop(${CMAKE_SOURCE_DIR} asteroid-qmltester)

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)
