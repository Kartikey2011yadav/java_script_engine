# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(java_script_engine_library VERSION 0.0.1 LANGUAGES C)

add_library(java_script_engine SHARED
        duktape.c                     # Modify
        )

set_target_properties(java_script_engine PROPERTIES
        PUBLIC_HEADER duktape.h       # Modify
        PRIVATE_HEADER duk_config.h   # Add
        OUTPUT_NAME "java_script_engine"      # Add
        )

# Add from here...
if (WIN32)
    set_target_properties(java_script_engine PROPERTIES
            WINDOWS_EXPORT_ALL_SYMBOLS ON
            )
endif (WIN32)
# ... to here.

target_compile_definitions(java_script_engine PUBLIC DART_SHARED_LIB)
