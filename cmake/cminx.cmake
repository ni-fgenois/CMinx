# Copyright 2021 CMakePP
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
include_guard()

set(CMAKEDOC_SRC "${CMAKE_CURRENT_LIST_DIR}/.." CACHE FILEPATH "Location of CMinx")


#[[[
# Generate documentation RST from source CMake files.
#
# :param dir: Directory to search for source files. Can also be a single file.
# :type dir: dir
# :param output: Directory to store output
# :type output: dir
# :param \*args: Optional arguments below. Pass to the function after all other parameters, order-sensitive.
#
# :Optional Arguments:
#    * *Prefix* (``string``) -- A prefix to be passed to CMinx. All files will have
#      the prefix prepended to their RST titles, and root-level files will have their
#      titles replaced by the prefix in recursive mode.
#]]
function(cminx_gen_rst _cgd_dir _cgd_output)
        set(_cgr_cminx_options "")
        if(IS_DIRECTORY "${_cgd_dir}")
            list(APPEND _cgr_cminx_options "-r")
        endif()

        if(${ARGC} GREATER 2)
            list(APPEND _cgr_cminx_options -p ${ARGV2})
        endif()

        execute_process(
            COMMAND
                "${CMINX_VENV_PYTHON_EXECUTABLE}"
                "${CMAKEDOC_SRC}/main.py"
                "${_cgd_dir}"
                ${_cgr_cminx_options}
                "-o" "${_cgd_output}"
            WORKING_DIRECTORY "${CMAKEDOC_SRC}"
            OUTPUT_VARIABLE process_output
            ERROR_VARIABLE process_err
            RESULT_VARIABLE process_result
        )

	message("${process_output}")
        if(NOT process_result EQUAL 0)
            message(FATAL_ERROR "Failed to generate RST. Result code was: ${process_result}. Error output was: ${process_err}. Process output was: ${process_output}")
        endif()

endfunction()

#[[[
# Add a custom target to the makefile called "docs" that calls Sphinx.
# Sphinx is automatically installed in the virtual environment and the target
# automatically uses that installed instance.
#
# :param _cad_doc_dir: Root directory of the sphinx docs where the makefile is located.
# :type _cad_doc_dir: dir
# :param _cad_output_dir: Directory where built docs will be placed
# :type _cad_output_dir: dir
# :param _cad_sphinx_target: Requested build target for Sphinx docs. Most common is "html".
# :type _cad_sphinx_target: desc
#]]
function(cminx_add_docs_target _cad_doc_dir _cad_output_dir _cad_sphinx_target)
	add_custom_target(docs COMMAND make "${_cad_sphinx_target}" "BUILDDIR=${_cad_output_dir}" "SPHINXBUILD=${CMINX_VENV_PYTHON_EXECUTABLE} -m sphinx" WORKING_DIRECTORY "${_cad_doc_dir}")
endfunction()

