cmake_minimum_required(VERSION 3.19)
project(PolynomialFractals LANGUAGES CXX CUDA)

# =========================
# Standardy
# =========================
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CUDA_STANDARD 17)

# =========================
# CUDA
# =========================
find_package(CUDAToolkit REQUIRED)

# =========================
# OpenGL
# =========================
find_package(OpenGL REQUIRED)

# =========================
# FreeGLUT
# =========================
add_subdirectory(external/freeglut)

# =========================
# Executable
# =========================
add_executable(${PROJECT_NAME}
    src/main.cpp
    src/complex.cuh
    src/cuda_kernels.h
    src/cuda_kernels.cu
    src/interactions.h
)

# =========================
# CUDA debug flags
# =========================
target_compile_options(${PROJECT_NAME} PRIVATE
    $<$<AND:$<COMPILE_LANGUAGE:CUDA>,$<CONFIG:Debug>>:-G -lineinfo>
)

# CUDA architecture
# =========================
set_property(TARGET ${PROJECT_NAME} PROPERTY CUDA_ARCHITECTURES 75;86;89)

# =========================
# CUDA settings
# =========================
#set_target_properties(${PROJECT_NAME} PROPERTIES
#    CUDA_RUNTIME_LIBRARY Shared
#)

# =========================
# Include directories
# =========================
target_include_directories(${PROJECT_NAME} PRIVATE
    ${OPENGL_INCLUDE_DIR}
)

# =========================
# Link libraries
# =========================
target_link_libraries(${PROJECT_NAME} PRIVATE
    OpenGL::GL
    freeglut
    CUDA::cudart
)

# =========================
# Windows specifics
# =========================
if (WIN32)
    target_compile_definitions(${PROJECT_NAME} PRIVATE FREEGLUT_STATIC)

    # Ścieżki do DLL w twoim buildzie FreeGLUT
    set(FREEGLUT_DLL_DEBUG "${CMAKE_BINARY_DIR}/external/freeglut/bin/Debug/freeglutd.dll")
    set(FREEGLUT_DLL_RELEASE "${CMAKE_BINARY_DIR}/external/freeglut/bin/Release/freeglut.dll")

    add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            $<$<CONFIG:Debug>:${FREEGLUT_DLL_DEBUG}>
            $<$<CONFIG:Release>:${FREEGLUT_DLL_RELEASE}>
            $<TARGET_FILE_DIR:${PROJECT_NAME}>
        COMMENT "Copying freeglut.dll to output directory"
    )
endif()