#!/bin/sh

. ./libraries/logging.sh

MODULES_DIRECTORY="./modules"
DOTFILES_SUBDIRECTORY="dotfiles"
SCRIPTS_SUBDIRECTORY="scripts"
SYMLINKS_FILE_NAME="symlinks.conf"

# function for processing a module's dotfiles
check_dotfiles() {
	if [ "$#" -ne 1 ]; then
		echo "usage: check_dotfiles <module_directory>"
	fi

	module_directory="$1"

	dotfiles_directory=$(realpath -s "$module_directory"/"$DOTFILES_SUBDIRECTORY")
	symlinks_file_path=$(realpath -s "$module_directory"/"$SYMLINKS_FILE_NAME")

	if [ ! -e "$symlinks_file_path" ]; then
		log_error "Symlinks file not found at '$symlinks_file_path'. Skipping..."
		return 1
	fi

	log_info "Symlinks file found at '$symlinks_file_path'. Processing..."

	# open file with descriptor 3
	exec 3<"$symlinks_file_path"

	# read line even if there is no newline at the end
	while IFS= read -r line || [ -n "$line" ]; do
		ln_link=$(echo "$line" | cut -d " " -f 1 | sed "s;~;$HOME;g")
		ln_link_path=$(realpath -s "$ln_link")
		ln_link_directory=$(dirname "$ln_link_path")

		ln_target=$(echo "$line" | cut -d " " -f 2)
		ln_target_path=$(realpath -s "$dotfiles_directory"/"$ln_target")

		if [ -e "$ln_target_path" ]; then
			log_info "Dotfile found at '$ln_target_path'. Continuing..."

			if [ -e "$ln_link_path" ] || [ -L "$ln_link_path" ]; then
				log_warn "File found at '$ln_link_path'. Removing..."

				if rm -f "$ln_link_path"; then
					log_info "File removed at '$ln_link_path'."
				else
					log_error "Could not remove file at '$ln_link_path'! Skipping..."
					continue
				fi
			else
				log_info "File not found at '$ln_link_path'. Continuing..."
			fi

			if [ ! -d "$ln_link_directory" ]; then
				log_warn "Directory not found at '$ln_link_directory'. Creating..."

				if mkdir -p "$ln_link_directory" 2>/dev/null; then
					log_info "Directory created at '$ln_link_directory'!"
				else
					log_error "Could not create directory at '$ln_link_directory'! Skipping..."
					continue
				fi
			else
				log_info "Directory found at '$ln_link_directory'. Continuing..."
			fi

			log_info "Linking dotfile '$ln_target_path' to '$ln_link_path'..."

			if ln -s "$ln_target_path" "$ln_link_path" 2>/dev/null; then
				log_info "Symbolic link created for '$ln_target_path' at '$ln_link_path'."
			else
				log_error "Could not create symbolic link at '$ln_link_path'! Skipping..."
				continue
			fi

		else
			log_error "Dotfile not found at '$ln_target_path'! Skipping..."
			continue
		fi
	done <&3

	# close file in descriptor 3
	exec 3<&-
}

# function for processing a module's scripts
check_scripts() {
	if [ "$#" -ne 1 ]; then
		echo "usage: check_scripts <module_directory>"
	fi

	module_directory=$(realpath -s "$1")
	scripts_directory=$(realpath -s "$module_directory"/"$SCRIPTS_SUBDIRECTORY")

	if [ ! -d "$scripts_directory" ]; then
		log_error "Scripts directory not found at '$scripts_directory'. Skipping..."
		return 1
	fi

	log_info "Scripts directory found at '$scripts_directory'. Processing..."

	for script_path in "$scripts_directory"/*.sh; do
		if [ -x "$script_path" ]; then
			log_info "Found executable script at '$script_path'. Running..." && /bin/sh "$script_path"
			log_info "Executable script at '$script_path' has exited with status code $?."
		else
			log_warn "Found non-executable script at '$script_path'. Skipping..."
			continue
		fi
	done
}

# function for starting the post-install process
bootstrap() {
	if [ "$#" -eq 0 ]; then
		echo "usage: $(basename "$0") <module1> [module2 ...]"
		return 1
	fi

	log_info "Started post-install process."

	for module in "$@"; do
		module_directory=$(realpath -s "$MODULES_DIRECTORY"/"$module")

		if [ ! -d "$module_directory" ]; then
			log_error "Module '$module' not found at '$module_directory'. Skipping..."
			continue
		fi

		log_info "Module '$module' found at '$module_directory'. Processing..."

		check_dotfiles "$module_directory"
		check_scripts "$module_directory"
	done

	log_info "Completed post-install process."
}

# pass script arguments to bootstrap function
bootstrap "$@"
