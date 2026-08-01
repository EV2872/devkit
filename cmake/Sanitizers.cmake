# ==============================================================================
# Sanitizers.cmake
# Habilita sanitizers de Clang/GCC solo en builds Debug
# ==============================================================================

option(ENABLE_SANITIZERS "Habilitar ASan/UBSan (o TSan) en Debug" ON)
option(ENABLE_THREAD_SANITIZER "Usar ThreadSanitizer en vez de ASan+UBSan" OFF)

function(devkit_enable_sanitizers target_name)
    if(NOT CMAKE_BUILD_TYPE STREQUAL "Debug" OR NOT ENABLE_SANITIZERS)
        return()
    endif()

    set(SANITIZERS "")
    list(APPEND SANITIZERS "address")
    list(APPEND SANITIZERS "undefined")

    if(NOT ENABLE_THREAD_SANITIZER)
        list(JOIN SANITIZERS "," SANITIZER_LIST)
        target_compile_options(${target_name} PRIVATE -fsanitize=${SANITIZER_LIST} -fno-omit-frame-pointer)
        target_link_options(${target_name} PRIVATE -fsanitize=${SANITIZER_LIST})
    else()
        target_compile_options(${target_name} PRIVATE -fsanitize=thread)
        target_link_options(${target_name} PRIVATE -fsanitize=thread)
    endif()
endfunction()