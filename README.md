# indi 3rd party drivers for arch linux

This repo contains the tools, that I use to maintain the indi 3rdparty drivers packages for arch linux.

## Usage

1. Update the version:

   ```bash
   > ./update-version.sh 2.1.7
   ```

2. Test building, and correct faults:

   ```bash
   > ./build_test.sh
   ```

3. When all packages pass, push the changes:

   ```bash
   > ./push.sh
   ```

   Use `ssh-agent` and `ssh-add` if your AUR private key is password protected
   in order to not have to re-type the password umpteen times.
   ```
