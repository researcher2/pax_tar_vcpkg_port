# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

# Currently Generates Static libs only. Supports both static and dynamic C Runtime linkage.

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO researcher2/pax_tar
    REF 1.0.0
    SHA512 bbbdd5b0a970dda46eac729e47ba6e8b9609825ded0c0db201b26a1447b6f4e1b5e145d8bae0a919aedba1c55cf4ed53f7df1d2800389d5a16c34c28e98c38e6
    HEAD_REF master
)

# Copy Includes
FILE(COPY            ${SOURCE_PATH}/src/pax_tar.h
     DESTINATION     ${CURRENT_PACKAGES_DIR}/include
     FILES_MATCHING PATTERN "*.h")

# Copy License
file(COPY ${SOURCE_PATH}/LICENSE 
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/pax-tar/copyright)
     
# Build depending on C Runtime Linking Type
if(VCPKG_CRT_LINKAGE STREQUAL static)    
    set(PROJECT_NAME pax_tar_lib_static)
else()
    set(PROJECT_NAME pax_tar_lib_dynamic)
endif()

vcpkg_build_msbuild(
    PROJECT_PATH "${SOURCE_PATH}/vs2017/${PROJECT_NAME}/${PROJECT_NAME}.vcxproj"
    OPTIONS /p:ForceImportBeforeCppTargets=${VCPKG_ROOT_DIR}/scripts/buildsystems/msbuild/vcpkg.targets
    OPTIONS_DEBUG /p:OutDir=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
    OPTIONS_RELEASE /p:OutDir=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
    OPTIONS /VERBOSITY:Diagnostic /DETAILEDSUMMARY
)

# Copy Debug Lib & PDB
file(COPY
    ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/${PROJECT_NAME}.lib
    ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/${PROJECT_NAME}.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    
# Copy Release Lib
file(COPY
    ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${PROJECT_NAME}.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

