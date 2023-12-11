#!/bin/bash

# The script generate a tree structure of the directories in the current directory and enhance the
# output using the content stored in the files .description in the respective folders.
# The generate output is injected in the file specified as a argument. The file must contain the
# following tags:
#
# <!-- BEGIN_FOLDER_STRUCTURE -->
# <!-- END_FOLDER_STRUCTURE -->
#
# All the content between these tags will be overwritten.
#
# Usage: ./generate-folder-structure.sh <path-to-input/output-file>

set -e
set -u
set -o pipefail

COMMENT_TRESHOLD=80

function generate_merged_tree_output() {
  local raw_tree
  local dir_name
  local dir_description
  local tree_output_suffix
  local merged_output=""

  # Limit the search to the first level to simplify the rest of the logic
  raw_tree=$(tree -d -L 1 -x --gitignore --prune --noreport)

  # For each directory found by tree, check if a file .description
  # is avaialble in the directory. If the file exists, merge the content with the tree output
  while IFS= read -r line ; do
    # the format of each line is something like this
    # ├── <DIR_NAME>
    # or
    # └── <DIR_NAME>
    dir_name=$(cut -d' ' -f2- <<< "${line}" )
    tree_output_suffix=""

    if ls -1 "${dir_name}/.description" > /dev/null 2>&1 ; then
      dir_description=$(head -n 1 < "${dir_name}/.description")
      length=$(wc -m <<< "${dir_description}")

      if [[ "${length}" -gt "${COMMENT_TRESHOLD}" ]]; then
        # Trim description if too long
        tree_output_suffix=$(cut -c -"${COMMENT_TRESHOLD}" <<< "${dir_description}")
        tree_output_suffix="${tree_output_suffix}..."
      else
        # Preserve original description
        tree_output_suffix="${dir_description}"
      fi

      # Improve readability in the output
      tree_output_suffix=" # ${tree_output_suffix}"
    fi

    merged_output="${merged_output}\n${line}${tree_output_suffix}";
  done <<< "${raw_tree}"

  echo -e "\`\`\`sh\n${merged_output}\n\`\`\`"
}

function main() {
  local input_file="${1}"
  local merged_tree
  local input_file_content
  local input_file_escaped
  local merged_tree_escaped
  local output_content_escaped
  local output_content_unescaped

  merged_tree=$(generate_merged_tree_output)
  # Backup original file
  cp "$1" "/tmp/original_file_$(date +%s)"
  input_file_content=$(cat "${input_file}")
  # Transform the input file into a single line string.
  # The variable substitution replace all the \n with \\n globally.
  input_file_escaped="${input_file_content//$'\n'/\\\\n}"
  # Escape all the \n in the string that must be injected.
  # This is necessary otherwise the sed command will complain.
  merged_tree_escaped="${merged_tree//$'\n'/\\\\\\\\n}"
  # Inject the merged tree into the escaped original file
  output_content_escaped=$(sed -r "s/(<!-- BEGIN_FOLDER_STRUCTURE -->).+(<!-- END_FOLDER_STRUCTURE -->)/\1${merged_tree_escaped}\n\2/" <<< "${input_file_escaped}")
  # Unescpace all the \\n
  output_content_unescaped="${output_content_escaped//\\n/\n}"
  # Do not use format string, let printf parse the escape chars contained in the variable.
  printf "$output_content_unescaped" > "${input_file}"
  info "Content injected into ${input_file}"
}

err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] $*" >&2
}

info() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] $*"
}

#######################################
# Entrypoint
#######################################
main "$@"