add_library(asteroid-qmltester main.cpp resources.qrc)
set_target_properties(asteroid-qmltester PROPERTIES PREFIX "" SUFFIX "")

target_link_libraries(asteroid-qmltester PUBLIC
	AsteroidApp)

install(TARGETS asteroid-qmltester
	DESTINATION ${CMAKE_INSTALL_BINDIR})
