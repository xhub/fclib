#
# FClib documentation with Doxygen 
#

# build in Generated DOCS
IF (NOT DOXYGEN_OUTPUT)
  SET(DOXYGEN_OUTPUT ${CMAKE_SOURCE_DIR}/web)
ENDIF(NOT DOXYGEN_OUTPUT)

# Style sheet
FILE(GLOB CSS_FILES config/css/*.*)
FOREACH(FILE ${CSS_FILES})
 IF(NOT IS_DIRECTORY ${FILE})
   FILE(RELATIVE_PATH RFILE ${CMAKE_SOURCE_DIR}/config/css ${FILE})
   MESSAGE(STATUS "Copy " ${FILE} " to " ${DOXYGEN_OUTPUT}/${RFILE})
   CONFIGURE_FILE(${FILE} ${DOXYGEN_OUTPUT}/${RFILE} COPYONLY)
 ENDIF(NOT IS_DIRECTORY ${FILE})
ENDFOREACH(FILE ${CSS_FILES})

# Images file
FILE(GLOB IMG_FILES config/images/*.*)
FOREACH(FILE ${IMG_FILES})
 IF(NOT IS_DIRECTORY ${FILE})
   FILE(RELATIVE_PATH RFILE ${CMAKE_SOURCE_DIR}/config/  ${FILE})
   MESSAGE(STATUS "Copy " ${FILE} " to " ${DOXYGEN_OUTPUT}/${RFILE})
   CONFIGURE_FILE(${FILE} ${DOXYGEN_OUTPUT}/${RFILE} COPYONLY)
 ENDIF(NOT IS_DIRECTORY ${FILE})
ENDFOREACH(FILE ${IMG_FILES})

# LATEX Style
FILE(GLOB LATEX_FILES config/*.sty)
FOREACH(FILE ${LATEX_FILES})
 IF(NOT IS_DIRECTORY ${FILE})
   FILE(RELATIVE_PATH RFILE ${CMAKE_SOURCE_DIR}/config/  ${FILE})
   MESSAGE(STATUS "Copy " ${FILE} " to " ${DOXYGEN_OUTPUT}/${RFILE})
   CONFIGURE_FILE(${FILE} ${DOXYGEN_OUTPUT}/${RFILE} COPYONLY)
 ENDIF(NOT IS_DIRECTORY ${FILE})
ENDFOREACH(FILE ${LATEX_FILES})

# PDF files
FILE(GLOB PDF ../doc/FCLib.pdf)
FOREACH(FILE ${PDF})
 IF(NOT IS_DIRECTORY ${FILE})
   FILE(RELATIVE_PATH RFILE ${CMAKE_SOURCE_DIR}/../  ${FILE})
   MESSAGE(STATUS "Copy " ${FILE} " to " ${DOXYGEN_OUTPUT}/${RFILE})
   CONFIGURE_FILE(${FILE} ${DOXYGEN_OUTPUT}/${RFILE} COPYONLY)
 ENDIF(NOT IS_DIRECTORY ${FILE})
ENDFOREACH(FILE ${PDF_FILES})


FILE(MAKE_DIRECTORY ${DOXYGEN_OUTPUT})
FILE(MAKE_DIRECTORY ${DOXYGEN_OUTPUT}/${PROJECT})
FILE(MAKE_DIRECTORY ${DOXYGEN_OUTPUT}/Tags)
FILE(MAKE_DIRECTORY ${DOXYGEN_OUTPUT}/images)
FILE(MAKE_DIRECTORY ${DOXYGEN_OUTPUT}/doc)


 # -helper macro to add a "doc" target with CMake build system. 
# and configure doxy.config.in to doxy.config
#
# target "doc" allows building the documentation with doxygen/dot on WIN32 and Linux
# Creates .chm windows help file if MS HTML help workshop 
# (available from http://msdn.microsoft.com/workshop/author/htmlhelp)
# is installed with its DLLs in PATH.
#
#
# Please note, that the tools, e.g.:
# doxygen, dot, latex, dvips, makeindex, gswin32, etc.
# must be in path.
#
# Note about Visual Studio Projects: 
# MSVS hast its own path environment which may differ from the shell.
# See "Menu Tools/Options/Projects/VC++ Directories" in VS 7.1
#
# author Jan Woetzel 2004-2006
# www.mip.informatik.uni-kiel.de/~jw


FIND_PACKAGE(Doxygen)

IF (DOXYGEN_FOUND)

  # click+jump in Emacs and Visual Studio (for doxy.config) (jw)
  IF    (CMAKE_BUILD_TOOL MATCHES "(msdev|devenv)")
    SET(DOXY_WARN_FORMAT "\"$file($line) : $text \"")
  ELSE  (CMAKE_BUILD_TOOL MATCHES "(msdev|devenv)")
    SET(DOXY_WARN_FORMAT "\"$file:$line: $text \"")
  ENDIF (CMAKE_BUILD_TOOL MATCHES "(msdev|devenv)")
  
  # we need latex for doxygen because of the formulas
  FIND_PACKAGE(LATEX)
  IF    (NOT LATEX_COMPILER)
    MESSAGE(STATUS "latex command LATEX_COMPILER not found but usually required. You will probably get warnings and user inetraction on doxy run.")
  ENDIF (NOT LATEX_COMPILER)
  IF    (NOT MAKEINDEX_COMPILER)
    MESSAGE(STATUS "makeindex command MAKEINDEX_COMPILER not found but usually required.")
  ENDIF (NOT MAKEINDEX_COMPILER)
  IF    (NOT DVIPS_CONVERTER)
    MESSAGE(STATUS "dvips command DVIPS_CONVERTER not found but usually required.")
  ENDIF (NOT DVIPS_CONVERTER)

  FIND_FILE(DOXY_CONFIG_IN
    NAMES doxy.config.in 
    PATHS ${CMAKE_CURRENT_SOURCE_DIR} 
    PATH_SUFFIXES . config doc etc doxygen)
  
  IF(DOXY_CONFIG_IN)
    GET_FILENAME_COMPONENT(PDOXY_CONFIG_IN ${DOXY_CONFIG_IN} PATH)
    
    FILE(RELATIVE_PATH RDOXY_CONFIG ${CMAKE_SOURCE_DIR} ${PDOXY_CONFIG_IN})
    CONFIGURE_FILE(${DOXY_CONFIG_IN}
      ${CMAKE_CURRENT_BINARY_DIR}/${RDOXY_CONFIG}/doxy.config
      @ONLY)
    SET(DOXY_CONFIG ${CMAKE_CURRENT_BINARY_DIR}/${RDOXY_CONFIG}/doxy.config)
  ELSE(DOXY_CONFIG_IN)
    IF   (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/doxy.config.in")
      MESSAGE(STATUS "configured ${CMAKE_CURRENT_SOURCE_DIR}/doxy.config.in --> ${CMAKE_CURRENT_BINARY_DIR}/doxy.config")
      CONFIGURE_FILE(${CMAKE_CURRENT_SOURCE_DIR}/doxy.config.in 
        ${CMAKE_CURRENT_BINARY_DIR}/doxy.config
        @ONLY )
      # use (configured) doxy.config from (out of place) BUILD tree:
      SET(DOXY_CONFIG "${CMAKE_CURRENT_BINARY_DIR}/doxy.config")
    ELSE (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/doxy.config.in")
      # use static hand-edited doxy.config from SOURCE tree:
      SET(DOXY_CONFIG "${CMAKE_CURRENT_SOURCE_DIR}/doxy.config")
      IF   (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/doxy.config")
        MESSAGE(STATUS "WARNING: using existing ${CMAKE_CURRENT_SOURCE_DIR}/doxy.config instead of configuring from doxy.config.in file.")
      ELSE (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/doxy.config")
        IF   (EXISTS "${CMAKE_MODULE_PATH}/doxy.config.in")
          # using template doxy.config.in
          MESSAGE(STATUS "configured ${CMAKE_CMAKE_MODULE_PATH}/doxy.config.in --> ${CMAKE_CURRENT_BINARY_DIR}/doxy.config")
          CONFIGURE_FILE(${CMAKE_MODULE_PATH}/doxy.config.in 
            ${CMAKE_CURRENT_BINARY_DIR}/doxy.config
            @ONLY )
          SET(DOXY_CONFIG "${CMAKE_CURRENT_BINARY_DIR}/doxy.config")
        ELSE (EXISTS "${CMAKE_MODULE_PATH}/doxy.config.in")
          # failed completely...
          MESSAGE(SEND_ERROR "Please create ${CMAKE_CURRENT_SOURCE_DIR}/doxy.config.in (or doxy.config as fallback)")
        ENDIF(EXISTS "${CMAKE_MODULE_PATH}/doxy.config.in")
        
      ENDIF(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/doxy.config")
    ENDIF(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/doxy.config.in")
    
  ENDIF(DOXY_CONFIG_IN)
  
  ADD_CUSTOM_TARGET(doc ${DOXYGEN_EXECUTABLE} ${DOXY_CONFIG} WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/${RDOXY_CONFIG})
  
  # create a windows help .chm file using hhc.exe
  # HTMLHelp DLL must be in path!
  # fallback: use hhw.exe interactively
  IF    (WIN32)
    FIND_PACKAGE(HTMLHelp)
    IF   (HTML_HELP_COMPILER)      
      SET (TMP "${CMAKE_CURRENT_BINARY_DIR}\\Doc\\html\\index.hhp")
      STRING(REGEX REPLACE "[/]" "\\\\" HHP_FILE ${TMP} )
      # MESSAGE(SEND_ERROR "DBG  HHP_FILE=${HHP_FILE}")
      ADD_CUSTOM_TARGET(winhelp ${HTML_HELP_COMPILER} ${HHP_FILE})
      ADD_DEPENDENCIES (winhelp doc)
     
      IF (NOT TARGET_DOC_SKIP_INSTALL)
      # install windows help?
      # determine useful name for output file 
      # should be project and version unique to allow installing 
      # multiple projects into one global directory      
      IF   (EXISTS "${PROJECT_BINARY_DIR}/Doc/html/index.chm")
        IF   (PROJECT_NAME)
          SET(OUT "${PROJECT_NAME}")
        ELSE (PROJECT_NAME)
          SET(OUT "Documentation") # default
        ENDIF(PROJECT_NAME)
        IF   (${PROJECT_NAME}_VERSION_MAJOR)
          SET(OUT "${OUT}-${${PROJECT_NAME}_VERSION_MAJOR}")
          IF   (${PROJECT_NAME}_VERSION_MINOR)
            SET(OUT  "${OUT}.${${PROJECT_NAME}_VERSION_MINOR}")
            IF   (${PROJECT_NAME}_VERSION_PATCH)
              SET(OUT "${OUT}.${${PROJECT_NAME}_VERSION_PATCH}")      
            ENDIF(${PROJECT_NAME}_VERSION_PATCH)
          ENDIF(${PROJECT_NAME}_VERSION_MINOR)
        ENDIF(${PROJECT_NAME}_VERSION_MAJOR)
        # keep suffix
        SET(OUT  "${OUT}.chm")
        
        #MESSAGE("DBG ${PROJECT_BINARY_DIR}/Doc/html/index.chm \n${OUT}")
        # create target used by install and package commands 
        INSTALL(FILES "${PROJECT_BINARY_DIR}/Doc/html/index.chm"
          DESTINATION "doc"
          RENAME "${OUT}"
        )
      ENDIF(EXISTS "${PROJECT_BINARY_DIR}/Doc/html/index.chm")
      ENDIF(NOT TARGET_DOC_SKIP_INSTALL)

    ENDIF(HTML_HELP_COMPILER)
    # MESSAGE(SEND_ERROR "HTML_HELP_COMPILER=${HTML_HELP_COMPILER}")
  ENDIF (WIN32) 
ENDIF(DOXYGEN_FOUND)

