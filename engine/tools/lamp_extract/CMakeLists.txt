cmake_minimum_required(VERSION 3.20)
project(lamp_extract C CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
include(${CMAKE_CURRENT_SOURCE_DIR}/../../cmake/VersionResource.cmake)

set(LAMP_EXTRACT_DEPS "" CACHE PATH "Folder holding the libmpq, zlib and bzip2 sources")
if(NOT EXISTS "${LAMP_EXTRACT_DEPS}/libmpq/libmpq/mpq.h")
    message(FATAL_ERROR "set -DLAMP_EXTRACT_DEPS=<folder holding libmpq, zlib and bzip2>")
endif()

set(LX_ZLIB_SOURCES adler32.c compress.c crc32.c deflate.c infback.c inffast.c inflate.c inftrees.c trees.c
    uncompr.c zutil.c)
list(TRANSFORM LX_ZLIB_SOURCES PREPEND ${LAMP_EXTRACT_DEPS}/zlib/)
add_library(lx_zlib STATIC ${LX_ZLIB_SOURCES})
target_include_directories(lx_zlib PUBLIC ${LAMP_EXTRACT_DEPS}/zlib)
target_compile_definitions(lx_zlib PRIVATE _CRT_SECURE_NO_WARNINGS _CRT_NONSTDC_NO_DEPRECATE)

file(GLOB LX_BZIP2_SOURCES ${LAMP_EXTRACT_DEPS}/bzip2/*.c)
add_library(lx_bzip2 STATIC ${LX_BZIP2_SOURCES})
target_include_directories(lx_bzip2 PUBLIC ${LAMP_EXTRACT_DEPS}/bzip2)
target_compile_definitions(lx_bzip2 PRIVATE _CRT_SECURE_NO_WARNINGS)

file(GLOB LX_MPQ_SOURCES ${LAMP_EXTRACT_DEPS}/libmpq/libmpq/*.c)
add_library(lx_mpq STATIC ${LX_MPQ_SOURCES})
target_include_directories(lx_mpq PUBLIC ${LAMP_EXTRACT_DEPS}/libmpq ${LAMP_EXTRACT_DEPS}/libmpq/win)
target_compile_definitions(lx_mpq PRIVATE _CRT_SECURE_NO_WARNINGS)
target_compile_options(lx_mpq PRIVATE /wd4103)
target_link_libraries(lx_mpq PUBLIC lx_zlib lx_bzip2)

add_executable(lamp_extract
    archive_set.cpp
    census.cpp
    dbc_table.cpp
    lamp_rules.cpp
    lamp_writer.cpp
    liquid_scan.cpp
    m2_lights.cpp
    main.cpp
    wmo_lights.cpp
    world_scan.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/../../src/lamp_catalog.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/../../src/liquid_map.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/../../src/log.cpp)
target_include_directories(lamp_extract PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../../src)
target_compile_definitions(lamp_extract PRIVATE WIN32_LEAN_AND_MEAN NOMINMAX _CRT_SECURE_NO_WARNINGS)
target_compile_options(lamp_extract PRIVATE /W4 /utf-8)
target_link_libraries(lamp_extract PRIVATE lx_mpq)
vf_version_resource(lamp_extract lamp_extract.exe VFT_APP
    "Lumenveil setup tool: lists the lamps and water of your game from its own data files")

add_executable(relief_pack
    archive_set.cpp
    blp_hash.cpp
    material_rules.cpp
    png_reader.cpp
    relief_pack.cpp
    relief_rules.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/../../src/relief_catalog.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/../../src/log.cpp)
target_include_directories(relief_pack PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../../src)
target_compile_definitions(relief_pack PRIVATE WIN32_LEAN_AND_MEAN NOMINMAX _CRT_SECURE_NO_WARNINGS)
target_compile_options(relief_pack PRIVATE /W4 /utf-8)
target_link_libraries(relief_pack PRIVATE lx_mpq)

add_executable(material_pack
    archive_set.cpp
    blp_hash.cpp
    material_pack.cpp
    material_rules.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/../../src/material_catalog.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/../../src/log.cpp)
target_include_directories(material_pack PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../../src)
target_compile_definitions(material_pack PRIVATE WIN32_LEAN_AND_MEAN NOMINMAX _CRT_SECURE_NO_WARNINGS)
target_compile_options(material_pack PRIVATE /W4 /utf-8)
target_link_libraries(material_pack PRIVATE lx_mpq)
