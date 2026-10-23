cmake_minimum_required(VERSION 3.20)
project(coa_vfog CXX)

if(NOT CMAKE_SIZEOF_VOID_P EQUAL 4)
    message(FATAL_ERROR "coa-vfog targets the 32-bit client; configure with -A Win32")
endif()

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")

option(VF_SYSTEM_CLIPBOARD "Let the settings window copy and paste through the Windows clipboard" OFF)
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/VersionResource.cmake)
set(VF_FOG_DATA ${CMAKE_CURRENT_SOURCE_DIR}/data/fogdata.bin)

file(GLOB FXC_CANDIDATES "$ENV{ProgramFiles\(x86\)}/Windows Kits/10/bin/10.*/x86/fxc.exe")
list(SORT FXC_CANDIDATES COMPARE NATURAL ORDER DESCENDING)
list(GET FXC_CANDIDATES 0 FXC_DEFAULT)
set(FXC "${FXC_DEFAULT}" CACHE FILEPATH "HLSL compiler (fxc.exe)")
if(NOT EXISTS "${FXC}")
    message(FATAL_ERROR "fxc.exe not found; install the Windows SDK or set -DFXC=<path>")
endif()

set(SHADER_DIR ${CMAKE_CURRENT_SOURCE_DIR}/shaders)
set(SHADER_OUT ${CMAKE_CURRENT_BINARY_DIR}/shaders)
file(MAKE_DIRECTORY ${SHADER_OUT})

set(SHADER_HEADERS)
function(vf_shader name source profile)
    set(out ${SHADER_OUT}/${name}.h)
    add_custom_command(
        OUTPUT ${out}
        COMMAND "${FXC}" /nologo /O3 /T ${profile} /E main /Vn g_${name} ${ARGN}
                /Fh ${out} /Fc ${SHADER_OUT}/${name}.asm ${SHADER_DIR}/${source}
        DEPENDS ${SHADER_DIR}/${source} ${SHADER_DIR}/vf_common.hlsli ${SHADER_DIR}/vf_lamp_table.hlsli
                ${SHADER_DIR}/vf_lamp_tiles.hlsli ${SHADER_DIR}/vf_surface_normal.hlsli
                ${SHADER_DIR}/vf_lamp_shadow.hlsli ${SHADER_DIR}/vf_memory.hlsli
                ${SHADER_DIR}/vf_water_surface.hlsli ${SHADER_DIR}/vf_water_memory.hlsli
                ${SHADER_DIR}/vf_water_rings.hlsli ${SHADER_DIR}/vf_clouds.hlsli
                ${SHADER_DIR}/vf_material_tag.hlsli
        COMMENT "fxc ${name}"
        VERBATIM)
    set(SHADER_HEADERS ${SHADER_HEADERS} ${out} PARENT_SCOPE)
endfunction()

vf_shader(vs_fullscreen vf_fullscreen_vs.hlsl vs_3_0)
vf_shader(ps_march_low vf_march.hlsl ps_3_0 /DSTEPS=16 /DSHAFT_STEPS=12)
vf_shader(ps_march_mid vf_march.hlsl ps_3_0 /DSTEPS=24 /DSHAFT_STEPS=16)
vf_shader(ps_march_high vf_march.hlsl ps_3_0 /DSTEPS=32 /DSHAFT_STEPS=24)
vf_shader(ps_march_memory_low vf_march.hlsl ps_3_0 /DSTEPS=16 /DSHAFT_STEPS=12 /DSHAFT_MEMORY=1)
vf_shader(ps_march_memory_mid vf_march.hlsl ps_3_0 /DSTEPS=24 /DSHAFT_STEPS=16 /DSHAFT_MEMORY=1)
vf_shader(ps_march_memory_high vf_march.hlsl ps_3_0 /DSTEPS=32 /DSHAFT_STEPS=24 /DSHAFT_MEMORY=1)
vf_shader(vs_memory_scatter vf_memory_scatter_vs.hlsl vs_3_0)
vf_shader(ps_memory_scatter vf_memory_scatter.hlsl ps_3_0)
vf_shader(ps_memory_keep vf_memory_keep.hlsl ps_3_0)
vf_shader(vs_memory_realign vf_memory_realign_vs.hlsl vs_3_0)
vf_shader(ps_memory_fill vf_memory_fill.hlsl ps_3_0)
vf_shader(ps_edge_occluders vf_edge_occluders.hlsl ps_3_0)
vf_shader(ps_temporal vf_temporal.hlsl ps_3_0)
vf_shader(ps_composite vf_composite.hlsl ps_3_0)
vf_shader(ps_ray_mask vf_ray_mask.hlsl ps_3_0)
vf_shader(ps_ray_blur vf_ray_blur.hlsl ps_3_0)
vf_shader(ps_glow_mask vf_glow_mask.hlsl ps_3_0)
vf_shader(ps_glow_blur vf_glow_blur.hlsl ps_3_0)
vf_shader(ps_probe vf_probe.hlsl ps_3_0)
vf_shader(ps_lamp_visibility vf_lamp_visibility.hlsl ps_3_0)
vf_shader(ps_lamps vf_lamps.hlsl ps_3_0)
vf_shader(ps_lamp_surfaces vf_lamp_surfaces.hlsl ps_3_0)
vf_shader(ps_lamp_blur vf_lamp_blur.hlsl ps_3_0)
vf_shader(ps_wet_surfaces vf_wet_surfaces.hlsl ps_3_0)
vf_shader(ps_water_depth vf_water_depth.hlsl ps_3_0)
vf_shader(ps_water vf_water.hlsl ps_3_0)
vf_shader(ps_water_reflect vf_water_reflect.hlsl ps_3_0)
vf_shader(ps_water_waves vf_water_waves.hlsl ps_3_0)
vf_shader(ps_water_slope vf_water_slope.hlsl ps_3_0)
vf_shader(ps_water_memory vf_water_memory.hlsl ps_3_0)
vf_shader(ps_water_lamps vf_water_lamps.hlsl ps_3_0)
vf_shader(ps_client_shadow vf_client_shadow.hlsl ps_3_0)
vf_shader(ps_effect_gather vf_effect_gather.hlsl ps_3_0)
vf_shader(ps_effect_reduce vf_effect_reduce.hlsl ps_3_0)
vf_shader(ps_sky_gather vf_sky_reference.hlsl ps_3_0 /DPASS=0)
vf_shader(ps_sky_columns vf_sky_reference.hlsl ps_3_0 /DPASS=1)
vf_shader(ps_sky_reference vf_sky_reference.hlsl ps_3_0 /DPASS=2)
vf_shader(ps_relief_1 vf_relief_terrain.hlsl ps_3_0 /DLAYERS=1)
vf_shader(ps_relief_2 vf_relief_terrain.hlsl ps_3_0 /DLAYERS=2)
vf_shader(ps_relief_3 vf_relief_terrain.hlsl ps_3_0 /DLAYERS=3)
vf_shader(ps_relief_4 vf_relief_terrain.hlsl ps_3_0 /DLAYERS=4)
vf_shader(ps_material_1 vf_relief_terrain.hlsl ps_3_0 /DLAYERS=1 /DRELIEF=0 /DMATERIAL=1)
vf_shader(ps_material_2 vf_relief_terrain.hlsl ps_3_0 /DLAYERS=2 /DRELIEF=0 /DMATERIAL=1)
vf_shader(ps_material_3 vf_relief_terrain.hlsl ps_3_0 /DLAYERS=3 /DRELIEF=0 /DMATERIAL=1)
vf_shader(ps_material_4 vf_relief_terrain.hlsl ps_3_0 /DLAYERS=4 /DRELIEF=0 /DMATERIAL=1)
vf_shader(ps_relief_material_1 vf_relief_terrain.hlsl ps_3_0 /DLAYERS=1 /DRELIEF=1 /DMATERIAL=1)
vf_shader(ps_relief_material_2 vf_relief_terrain.hlsl ps_3_0 /DLAYERS=2 /DRELIEF=1 /DMATERIAL=1)
vf_shader(ps_relief_material_3 vf_relief_terrain.hlsl ps_3_0 /DLAYERS=3 /DRELIEF=1 /DMATERIAL=1)
vf_shader(ps_relief_material_4 vf_relief_terrain.hlsl ps_3_0 /DLAYERS=4 /DRELIEF=1 /DMATERIAL=1)
vf_shader(ps_relief_model vf_relief_model.hlsl ps_3_0)
vf_shader(ps_relief_model_material vf_relief_model.hlsl ps_3_0 /DRELIEF=1 /DMATERIAL=1)
vf_shader(ps_model_material vf_relief_model.hlsl ps_3_0 /DRELIEF=0 /DMATERIAL=1)
add_custom_target(vf_shaders DEPENDS ${SHADER_HEADERS})

set(SHADER_HEADERS)
vf_shader(vs_test_replay ../tests/replay_vs.hlsl vs_3_0)
vf_shader(ps_test_replay ../tests/replay_ps.hlsl ps_3_0)
vf_shader(vs_test_caster ../tests/caster_vs.hlsl vs_3_0)
vf_shader(ps_test_caster ../tests/caster_ps.hlsl ps_3_0)
vf_shader(vs_test_model_receiver ../tests/receiver_vs.hlsl vs_3_0 /DSHADOW_ROWS=c224)
vf_shader(vs_test_terrain_receiver ../tests/receiver_vs.hlsl vs_3_0 /DSHADOW_ROWS=c37)
vf_shader(ps_test_terrain_1 ../tests/terrain_ps.hlsl ps_3_0 /DLAYERS=1)
vf_shader(vs_test_terrain_1 ../tests/terrain_vs.hlsl vs_3_0 /DLAYERS=1)
vf_shader(ps_test_terrain_2 ../tests/terrain_ps.hlsl ps_3_0 /DLAYERS=2)
vf_shader(vs_test_terrain_2 ../tests/terrain_vs.hlsl vs_3_0 /DLAYERS=2)
vf_shader(ps_test_terrain_3 ../tests/terrain_ps.hlsl ps_3_0 /DLAYERS=3)
vf_shader(vs_test_terrain_3 ../tests/terrain_vs.hlsl vs_3_0 /DLAYERS=3)
vf_shader(ps_test_terrain_4 ../tests/terrain_ps.hlsl ps_3_0 /DLAYERS=4)
vf_shader(vs_test_terrain_4 ../tests/terrain_vs.hlsl vs_3_0 /DLAYERS=4)
vf_shader(vs_test_terrain_no_view ../tests/terrain_vs.hlsl vs_3_0 /DLAYERS=4 /DNO_VIEW_POSITION=1)
vf_shader(ps_test_model ../tests/model_ps.hlsl ps_3_0)
vf_shader(vs_test_model_unlit ../tests/model_vs.hlsl vs_3_0 /DFORM=0)
vf_shader(vs_test_model_ratio ../tests/model_vs.hlsl vs_3_0 /DFORM=1)
vf_shader(vs_test_model_additive ../tests/model_vs.hlsl vs_3_0 /DFORM=2)
vf_shader(vs_test_model_creature ../tests/model_vs.hlsl vs_3_0 /DFORM=3)
vf_shader(vs_test_model_two_uv ../tests/model_vs.hlsl vs_3_0 /DFORM=1 /DUV_SETS=2)
vf_shader(vs_test_model_sphere ../tests/model_vs.hlsl vs_3_0 /DFORM=1 /DSPHERE_UV=1)
add_custom_target(vf_test_shaders DEPENDS ${SHADER_HEADERS})

include(FetchContent)
if(POLICY CMP0135)
    cmake_policy(SET CMP0135 NEW)
endif()
FetchContent_Declare(imgui
    URL https://github.com/ocornut/imgui/archive/refs/tags/v1.92.9b.tar.gz
    URL_HASH SHA256=21d8a0a565e85dce943e375db00812c2f3f0ab21f3f0f7964e364a63422d7f99)
FetchContent_MakeAvailable(imgui)

add_library(imgui STATIC
    ${imgui_SOURCE_DIR}/imgui.cpp
    ${imgui_SOURCE_DIR}/imgui_demo.cpp
    ${imgui_SOURCE_DIR}/imgui_draw.cpp
    ${imgui_SOURCE_DIR}/imgui_tables.cpp
    ${imgui_SOURCE_DIR}/imgui_widgets.cpp
    ${imgui_SOURCE_DIR}/backends/imgui_impl_dx9.cpp
    ${imgui_SOURCE_DIR}/backends/imgui_impl_win32.cpp)
target_include_directories(imgui PUBLIC ${imgui_SOURCE_DIR} ${imgui_SOURCE_DIR}/backends)
target_compile_definitions(imgui
    PUBLIC IMGUI_DISABLE_DEMO_WINDOWS IMGUI_DISABLE_DEBUG_TOOLS
    PRIVATE IMGUI_IMPL_WIN32_DISABLE_GAMEPAD IMGUI_DISABLE_WIN32_DEFAULT_IME_FUNCTIONS
            IMGUI_DISABLE_DEFAULT_SHELL_FUNCTIONS WIN32_LEAN_AND_MEAN NOMINMAX)
if(NOT VF_SYSTEM_CLIPBOARD)
    target_compile_definitions(imgui PRIVATE IMGUI_DISABLE_WIN32_DEFAULT_CLIPBOARD_FUNCTIONS)
endif()

add_library(CoAVolFog SHARED
    src/belt_lantern.cpp
    src/corpse_lights.cpp
    src/client_shadows.cpp
    src/client_world.cpp
    src/cloud_noise.cpp
    src/config.cpp
    src/d3d9_wrap.cpp
    src/dllmain.cpp
    src/draw_log.cpp
    src/drift_noise.cpp
    src/effect_lights.cpp
    src/engine.cpp
    src/fog_data.cpp
    src/fog_model.cpp
    src/hooks.cpp
    src/lamp_catalog.cpp
    src/lamp_selection.cpp
    src/liquid_map.cpp
    src/log.cpp
    src/material_catalog.cpp
    src/overlay.cpp
    src/region_panel.cpp
    src/region_settings.cpp
    src/region_zones.cpp
    src/regions.cpp
    src/relief_catalog.cpp
    src/renderer.cpp
    src/settings_panel.cpp
    src/shader_splice.cpp
    src/sky_filter.cpp
    src/lamp_tiles.cpp
    src/frame_profile.cpp
    src/spots.cpp
    src/runtime_heights.cpp
    src/terrain_relief.cpp
    src/terrain_shadow.cpp
    src/water_lamps.cpp
    src/water_rain.cpp
    src/water_ripples.cpp
    src/water_rings.cpp
    src/water_waves.cpp
    src/wet_surfaces.cpp
    src/world_controls.cpp
    src/CoAVolFog.def)
add_dependencies(CoAVolFog vf_shaders)
target_include_directories(CoAVolFog PRIVATE src ${SHADER_OUT})
target_compile_definitions(CoAVolFog PRIVATE WIN32_LEAN_AND_MEAN NOMINMAX _CRT_SECURE_NO_WARNINGS)
target_compile_options(CoAVolFog PRIVATE /W4 /wd4100 /arch:SSE2 /fp:fast /GS)
target_link_libraries(CoAVolFog PRIVATE kernel32 user32 imgui)
vf_version_resource(CoAVolFog CoAVolFog.dll VFT_DLL
    "Lumenveil renderer: fog, light and water effects drawn on the game's Direct3D 9 device")

add_library(version SHARED proxy/version_proxy.cpp proxy/version.def)
target_link_libraries(version PRIVATE CoAVolFog)
target_compile_definitions(version PRIVATE WIN32_LEAN_AND_MEAN)
vf_version_resource(version version.dll VFT_DLL
    "Lumenveil loader: passes the Windows version API on to the system's version.dll and loads CoAVolFog.dll")

add_executable(vfog_harness tests/harness.cpp src/belt_lantern.cpp src/cloud_noise.cpp src/config.cpp
    src/corpse_lights.cpp src/drift_noise.cpp src/effect_lights.cpp src/fog_data.cpp src/fog_model.cpp src/lamp_catalog.cpp
    src/lamp_selection.cpp src/lamp_tiles.cpp src/liquid_map.cpp src/log.cpp src/material_catalog.cpp src/region_settings.cpp
    src/region_zones.cpp src/relief_catalog.cpp src/runtime_heights.cpp
    src/shader_splice.cpp src/spots.cpp
    src/terrain_shadow.cpp src/water_lamps.cpp src/water_rain.cpp
    src/water_ripples.cpp src/water_rings.cpp src/water_waves.cpp src/wet_surfaces.cpp src/world_controls.cpp
    tools/lamp_extract/lamp_rules.cpp tools/lamp_extract/material_rules.cpp
    tools/lamp_extract/relief_rules.cpp)
target_include_directories(vfog_harness PRIVATE src tools/lamp_extract ${SHADER_OUT})
add_dependencies(vfog_harness vf_test_shaders)
target_compile_definitions(vfog_harness PRIVATE WIN32_LEAN_AND_MEAN NOMINMAX _CRT_SECURE_NO_WARNINGS)
target_compile_definitions(vfog_harness PRIVATE VF_VERSION_TEXT="${VF_VERSION}"
    $<$<BOOL:${VF_SYSTEM_CLIPBOARD}>:VF_SYSTEM_CLIPBOARD>)
target_link_libraries(vfog_harness PRIVATE CoAVolFog user32 ole32 windowscodecs)
set(VF_POST_BUILD_FILES ${CMAKE_CURRENT_SOURCE_DIR}/CoAVolFog.ini)
if(EXISTS ${VF_FOG_DATA})
    list(APPEND VF_POST_BUILD_FILES ${VF_FOG_DATA})
endif()
add_custom_command(TARGET CoAVolFog POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${VF_POST_BUILD_FILES} $<TARGET_FILE_DIR:CoAVolFog>)

enable_testing()
add_test(NAME vfog_harness
    COMMAND vfog_harness --out ${CMAKE_CURRENT_BINARY_DIR}/harness-out
            --data ${VF_FOG_DATA}
            --ini ${CMAKE_CURRENT_SOURCE_DIR}/CoAVolFog.ini
    WORKING_DIRECTORY $<TARGET_FILE_DIR:vfog_harness>)

find_package(Python3 COMPONENTS Interpreter)
if(Python3_Interpreter_FOUND)
    add_test(NAME comments
        COMMAND Python3::Interpreter ${CMAKE_CURRENT_SOURCE_DIR}/tools/check_comments.py
                --root ${CMAKE_CURRENT_SOURCE_DIR})
endif()
