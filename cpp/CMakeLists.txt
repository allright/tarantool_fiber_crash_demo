project(fiber_crash_demo)
cmake_minimum_required(VERSION 3.13)

set (CMAKE_CXX_STANDARD 11)

if (APPLE)
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -undefined suppress -flat_namespace")
    link_directories(/usr/local/lib/)
    include_directories(/usr/local/include/lua5.1
            /usr/local/include/tarantool
            /usr/local/Cellar/msgpuck/2.0/include
            /usr/local/Cellar/ffmpeg/4.4.1_3/include)
#else()
#    include_directories(/ffmpeg-build/include)
#    link_directories(/ffmpeg-build/lib)
endif(APPLE)


    include_directories(/usr/local/include/lua5.1
            /usr/local/include/tarantool)

file(GLOB_RECURSE SRC *.cpp)
add_library(${CMAKE_PROJECT_NAME} SHARED ${SRC})

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")

target_compile_options(${CMAKE_PROJECT_NAME} PRIVATE -fno-exceptions -fPIC -Werror)
add_definitions(-D__STDC_CONSTANT_MACROS)

if (NOT APPLE)
    target_link_libraries(${CMAKE_PROJECT_NAME} -static-libstdc++)
endif()
set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES PREFIX "" SUFFIX ".so" OUTPUT_NAME ${CMAKE_PROJECT_NAME})
