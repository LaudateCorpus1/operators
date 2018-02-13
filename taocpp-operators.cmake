set (TAOCPP_OPERATORS_LIBRARY taocpp-operators)
set (TAOCPP_OPERATORS_INCLUDE_DIRS ${CMAKE_CURRENT_LIST_DIR}/include)

file (GLOB_RECURSE TAOCPP_OPERATORS_INCLUDE_FILES ${TAOCPP_OPERATORS_INCLUDE_DIRS}/*.hpp)

source_group ("Header Files" FILES ${TAOCPP_OPERATORS_INCLUDE_FILES})

add_library (${TAOCPP_OPERATORS_LIBRARY} INTERFACE)
add_library (taocpp::operators ALIAS ${TAOCPP_OPERATORS_LIBRARY})

target_include_directories (${TAOCPP_OPERATORS_LIBRARY} INTERFACE ${TAOCPP_OPERATORS_INCLUDE_DIRS})

target_compile_features (${TAOCPP_OPERATORS_LIBRARY} INTERFACE
  cxx_noexcept
  cxx_rvalue_references
)
