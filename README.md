# Shell Script

<p align="right">
 <a href="https://github.com/homelab-alpha/shell-script/actions/workflows/super-linter.yml">
  <img
   src="https://github.com/homelab-alpha/shell-script/actions/workflows/super-linter.yml/badge.svg?branch=main"
   alt="Super-Linter"
  />
 </a>
</p>

Welcome to my shell-script repository! this repository contains a collection of useful shell scripts for various purposes.

## Introduction

Shell script are plain text files containing commands that are interpreted and executed by the shell. They are commonly used for automating tasks, managing system configurations, and performing various operations in Unix-like operating systems.

## Usage

Each shell script in this repository is self-contained and can be run directly from the command-line. Before executing a script, ensure that you have the necessary permissions and dependencies installed on your system.

To run a shell script, navigate to its location in the terminal and execute the following command:

```bash
./script_name.sh
```

Replace `script_name.sh` with the name of the script you want to run.

## Scripts

Here's a brief overview of the scripts available in this repository:

- `check_pi_throttling.sh`: This script checks the status of the Raspberry Pi for throttling issues.
- `gnome_keybindings_backup_restore.sh`: This script allows you to easily create backups of GNOME keybindings and restore them when needed.
- `maintain_git_repo`: This script will Maintain your Git repository typically involves reducing a repository size.
- `new_docker_compose_file`: This Script will creating a new Docker Compose file template.
- `ssh_keygen_script.sh`: This script will generating and converting SSH key pairs for secure server access.
- `user_accounts_info.sh`: This script shows your user and groups ID.
- ...

Feel free to explore each script's documentation for detailed usage instructions.

## Log Files

The location of log files can vary depending on the specific operating system and application being used. Log files are often stored in a subdirectory within the application's installation directory or in a system directory such as `/var/log` on Linux

## Contribution

Contributions to this repository are welcome! If you have a shell script that you believe would be valuable to others, feel free to open a pull request. Pleas make sure your script is well documented and follows best practices. Read more about [contributing to this project](CONTRIBUTING.md) for more information.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE.md) file for details.

## Acknowledgements

- [ShellCheck](https://www.shellcheck.net/): A tool for analyzing shell scripts and providing suggestions for improvement.
- [Bash Scripting Guide](https://www.tldp.org/LDP/abs/html/): A comprehensive guide to bash scripting.

## Contact

If you have any questions, suggestions, or issues, please feel free to open an [issue] or [pull request].

Happy scripting!

[issue]: https://github.com/homelab-alpha/shell-script/issues/new
[pull request]: https://github.com/homelab-alpha/shell-script/pulls
