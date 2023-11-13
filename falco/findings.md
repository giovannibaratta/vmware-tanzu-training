* Using `kind: module` in vSphere 8 with `VMware Photon OS/Linux   4.19.256-4.ph3-esx` results in `Init:CrashLoopBackOff`. The driver loader is not able to load the module into the kernel.
    ```
    kubectl logs falco-x6pgk -c falco-driver-loader
    * Setting up /usr/src links from host
    * Running falco-driver-loader for: falco version=0.36.2, driver version=6.0.1+driver, arch=x86_64, kernel release=4.19.256-4.ph3-esx, kernel version=1
    * Running falco-driver-loader with: driver=module, compile=yes, download=yes

    ================ Cleaning phase ================

    * 1. Check if kernel module 'falco' is still loaded:
    - OK! There is no 'falco' module loaded.

    * 2. Check all versions of kernel module 'falco' in dkms:
    - OK! There are no 'falco' module versions in dkms.

    [SUCCESS] Cleaning phase correctly terminated.

    ================ Cleaning phase ================

    * Looking for a falco module locally (kernel 4.19.256-4.ph3-esx)
    * Filename 'falco_photon_4.19.256-4.ph3-esx_1.ko' is composed of:
    - driver name: falco
    - target identifier: photon
    - kernel release: 4.19.256-4.ph3-esx
    - kernel version: 1
    * Trying to download a prebuilt falco module from https://download.falco.org/driver/6.0.1%2Bdriver/x86_64/falco_photon_4.19.256-4.ph3-esx_1.ko
    curl: (22) The requested URL returned error: 404
    Unable to find a prebuilt falco module
    install: /usr/lib/gcc/x86_64-linux-gnu/12/
    * Trying to dkms install falco module with GCC /usr/bin/gcc
    Sign command: /lib/modules/4.19.256-4.ph3-esx/build/scripts/sign-file
    Binary /lib/modules/4.19.256-4.ph3-esx/build/scripts/sign-file not found, modules won't be signed
    DIRECTIVE: MAKE="'/tmp/falco-dkms-make'"
    Creating symlink /var/lib/dkms/falco/6.0.1+driver/source -> /usr/src/falco-6.0.1+driver
    * Running dkms build failed, couldn't find /var/lib/dkms/falco/6.0.1+driver/build/make.log (with GCC /usr/bin/gcc)
    install: /usr/lib/gcc/x86_64-linux-gnu/11/
    * Trying to dkms install falco module with GCC /usr/bin/gcc-11
    Sign command: /lib/modules/4.19.256-4.ph3-esx/build/scripts/sign-file
    Binary /lib/modules/4.19.256-4.ph3-esx/build/scripts/sign-file not found, modules won't be signed
    DIRECTIVE: MAKE="'/tmp/falco-dkms-make'"
    * Running dkms build failed, couldn't find /var/lib/dkms/falco/6.0.1+driver/build/make.log (with GCC /usr/bin/gcc-11)
    install: /usr/lib/gcc/x86_64-linux-gnu/12/
    * Trying to dkms install falco module with GCC /usr/bin/gcc-12
    Sign command: /lib/modules/4.19.256-4.ph3-esx/build/scripts/sign-file
    Binary /lib/modules/4.19.256-4.ph3-esx/build/scripts/sign-file not found, modules won't be signed
    DIRECTIVE: MAKE="'/tmp/falco-dkms-make'"
    * Running dkms build failed, couldn't find /var/lib/dkms/falco/6.0.1+driver/build/make.log (with GCC /usr/bin/gcc-12)
    * Trying to load a system falco module, if present
    Consider compiling your own falco driver and loading it or getting in touch with the Falco community
    ```
