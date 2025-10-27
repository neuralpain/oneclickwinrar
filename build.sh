#!/bin/bash

# Copyright (c) 2025, neuralpain
# https://github.com/neuralpain/oneclickwinrar
# Build system for oneclickwinrar

set -e

OCWR_VERSION=$(<VERSION)
SRC_DIR="src"
BUILD_DIR="build"
TPL_HEADER="$SRC_DIR/templates/batch_header.cmd"

UTILITIES_MODULES=(
  "$SRC_DIR/includes/common/Logging.ps1"
  "$SRC_DIR/includes/common/Format-Text.ps1"
  "$SRC_DIR/includes/common/New-Toast.ps1"
  "$SRC_DIR/includes/common/Stop-OcwrOperation.ps1"
)

ONECLICK_DATA_PROCESSING=(
  "$SRC_DIR/includes/core/oneclick/Get-SpecialCode.ps1"
  "$SRC_DIR/includes/core/oneclick/Confirm-ScriptNamePosition.ps1"
  "$SRC_DIR/includes/core/oneclick/Confirm-SpecialSwitch.ps1"
  "$SRC_DIR/includes/core/oneclick/Get-DataFromConfig.ps1"
  "$SRC_DIR/includes/core/oneclick/Set-OcwrOperationMode.ps1"
  "$SRC_DIR/includes/core/oneclick/Confirm-DownloadConfig.ps1"
)

DATA_PROCESSING_MODULES=(
  "$SRC_DIR/includes/core/language.ps1"
)

inject_modules() {
  local placeholder="$1"
  local target_file="$2"
  shift 2
  local modules_array=("$@")

  if ! grep -q "$placeholder" "$target_file"; then
    return
  fi

  local combined_modules_file=$(mktemp)

  for module_file in "${modules_array[@]}"; do
    if [ -f "$module_file" ]; then
      cat "$module_file" >> "$combined_modules_file"
      echo "" >> "$combined_modules_file" # Add a newline for spacing
    fi
  done

  # If the combined file is empty (no valid modules found), just delete the placeholder
  if [ ! -s "$combined_modules_file" ]; then
   sed -i "/$placeholder/d" "$target_file"
  else
   sed -i -e "/$placeholder/r $combined_modules_file" -e "/$placeholder/d" "$target_file"
  fi

  rm "$combined_modules_file"
}

patch() {
  local file_to_patch="$1"
  local placeholder="$2"
  local patch_file="$3"

  if [ -f "$patch_file" ]; then sed -i -e "/$placeholder/r $patch_file" -e "/$placeholder/d" "$file_to_patch"; fi
}

# These patches are for very specific differences in functions between scripts
apply_patches() {
  local target_name="$1"
  local file_to_patch="$2"

  echo " -> Applying specific patches for $target_name..."

  case "$target_name" in
    "oneclickrar")
      patch "$file_to_patch" '#####LICENSE_PRECHECK#####' "$SRC_DIR/includes/patches/oneclickrar_license_precheck.ps1"
      patch "$file_to_patch" '#####EXISTING_LICENSE_ERROR#####' "$SRC_DIR/includes/patches/oneclickrar_license_error.ps1"
      patch "$file_to_patch" '#####KNOWN_VERSION_LIST#####' "$SRC_DIR/includes/patches/winrar_version_list.ps1"
      patch "$file_to_patch" '#####KNOWN_LANGUAGE_LIST#####' "$SRC_DIR/includes/patches/winrar_language_list.ps1"
      patch "$file_to_patch" '#####STATUS_CODES#####' "$SRC_DIR/includes/patches/status_codes.ps1"
      patch "$file_to_patch" '#####INSTALLATION_SET_LOCATION#####' "$SRC_DIR/includes/patches/oneclickrar_installation_set_location.ps1"
      patch "$file_to_patch" '#####MESSAGES_INSTALLRAR#####' "$SRC_DIR/includes/messages/messages_installrar.ps1"
      patch "$file_to_patch" '#####MESSAGES_LICENSERAR#####' "$SRC_DIR/includes/messages/messages_licenserar.ps1"
      patch "$file_to_patch" '#####MESSAGES_UNLICENSERAR#####' "$SRC_DIR/includes/messages/messages_unlicenserar.ps1"

      ;; # END

    "installrar")
      patch "$file_to_patch" '#####KNOWN_VERSION_LIST#####' "$SRC_DIR/includes/patches/winrar_version_list.ps1"
      patch "$file_to_patch" '#####KNOWN_LANGUAGE_LIST#####' "$SRC_DIR/includes/patches/winrar_language_list.ps1"
      patch "$file_to_patch" '#####STATUS_CODES#####' "$SRC_DIR/includes/patches/status_codes.ps1"
      ;; # END

    "licenserar")
      patch "$file_to_patch" '#####LICENSE_PRECHECK#####' "$SRC_DIR/includes/patches/licenserar_license_precheck.ps1"
      patch "$file_to_patch" '#####EXISTING_LICENSE_ERROR#####' "$SRC_DIR/includes/patches/licenserar_license_error.ps1"
      ;; # END
  esac

  echo " -> Applying message patches..."

  inject_modules "#####SHARED_MESSAGES#####" "$temp_ps_file" "$SRC_DIR/includes/messages/messages_shared.ps1"
}

build_script() {
  local target_name="$1"
  local description="$2"
  local template_file="$SRC_DIR/templates/$target_name.template.ps1"
  local temp_ps_file="$BUILD_DIR/$target_name.tmp.ps1"
  local final_cmd_file="$BUILD_DIR/$target_name.cmd"

  echo "Building $final_cmd_file..."

  cp "$template_file" "$temp_ps_file"

  inject_modules "#####UTILITIES#####" "$temp_ps_file" "${UTILITIES_MODULES[@]}"
  inject_modules "#####CONFIRM_QUERY#####" "$temp_ps_file" "$SRC_DIR/includes/common/Confirm-QueryResult.ps1"
  inject_modules "#####VERSION_FORMAT#####" "$temp_ps_file" "$SRC_DIR/includes/common/version_format.ps1"
  inject_modules "#####LOCATIONS#####" "$temp_ps_file" "$SRC_DIR/includes/common/Locations.ps1"
  inject_modules "#####DEFAULT_ARCH_VERSION#####" "$temp_ps_file" "$SRC_DIR/includes/common/Defaults.ps1"
  inject_modules "#####TITLE_HEADER#####" "$temp_ps_file" "$SRC_DIR/includes/common/Title.ps1"
  inject_modules "#####SELECT_WINRAR_INSTALLATION#####" "$temp_ps_file" "$SRC_DIR/includes/common/Select-WinrarInstallation.ps1"

  inject_modules "#####MESSAGES#####" "$temp_ps_file" "$SRC_DIR/includes/messages/messages_$target_name.ps1"

  inject_modules "#####UPDATES#####" "$temp_ps_file" "$SRC_DIR/includes/core/updates.ps1"
  inject_modules "#####LANG_PROCESSING#####" "$temp_ps_file" "$SRC_DIR/includes/core/Get-LanguageName.ps1"

  inject_modules "#####ONECLICK_DATA_PROCESSING#####" "$temp_ps_file" "${ONECLICK_DATA_PROCESSING[@]}"
  inject_modules "#####DATA_PROCESSING#####" "$temp_ps_file" "$SRC_DIR/includes/core/data_processing_$target_name.ps1"

  inject_modules "#####INSTALLATION#####" "$temp_ps_file" "$SRC_DIR/includes/core/installation.ps1"
  inject_modules "#####LICENSING#####" "$temp_ps_file" "$SRC_DIR/includes/core/licensing.ps1"
  inject_modules "#####UNINSTALLATION#####" "$temp_ps_file" "$SRC_DIR/includes/core/uninstallation.ps1"
  inject_modules "#####UNLICENSING#####" "$temp_ps_file" "$SRC_DIR/includes/core/unlicensing.ps1"

  apply_patches "$target_name" "$temp_ps_file"

  local temp_header=$(mktemp)
  sed "s/SCRIPT_NAME_SHORT/$target_name/g; s/SCRIPT_VERSION/$OCWR_VERSION/g; s/BUNDLE_TIMESTAMP/$(date "+%y%m%d%H%M%S")/g; s/SCRIPT_NAME/$target_name.cmd/g; s/SCRIPT_DESCRIPTION/$description/g" "$TPL_HEADER" > "$temp_header"

  local temp_final_ps_file=$(mktemp)
  sed "s/#####OCWR_VERSION#####/$OCWR_VERSION/g" "$temp_ps_file" > "$temp_final_ps_file"

  {
   cat "$temp_header"
   cat "$temp_final_ps_file"
  } > "$final_cmd_file"

  rm "$temp_ps_file" # comment this to keep the .ps1 file for debugging
  rm "$temp_header"
  echo "Successfully built $final_cmd_file"
}

echo "Starting build process..."
mkdir -p "$BUILD_DIR"

build_script "oneclickrar" "Install and license WinRAR"
build_script "installrar" "Install WinRAR"
build_script "licenserar" "License WinRAR"
build_script "unlicenserar" "Un-license WinRAR"

echo -e "\nBuild process completed."
