                                   ___                __                        
                                  /\_ \    __        /\ \                       
        ___     ___      __    ___\//\ \  /\_\    ___\ \ \/'\                   
       / __`\ /' _ `\  /'__`\ /'___\\ \ \ \/\ \  /'___\ \ , <                   
      /\ \L\ \/\ \/\ \/\  __//\ \__/ \_\ \_\ \ \/\ \__/\ \ \\`\                 
      \ \____/\ \_\ \_\ \____\ \____\/\____\\ \_\ \____\\ \_\ \_\               
       \/___/  \/_/\/_/\/____/\/____/\/____/ \/_/\/____/ \/_/\/_/               
            __      __              ____    ______  ____                        
           /\ \  __/\ \  __        /\  _`\ /\  _  \/\  _`\                      
           \ \ \/\ \ \ \/\_\    ___\ \ \L\ \ \ \L\ \ \ \L\ \                    
            \ \ \ \ \ \ \/\ \ /' _ `\ \ ,  /\ \  __ \ \ ,  /                    
             \ \ \_/ \_\ \ \ \/\ \/\ \ \ \\ \\ \ \/\ \ \ \\ \                   
              \ `\___x___/\ \_\ \_\ \_\ \_\ \_\ \_\ \_\ \_\ \_\                 
               '\/__//__/  \/_/\/_/\/_/\/_/\/ /\/_/\/_/\/_/\/ /  v0.13.0.713    


oneclickwinrar - install and license WinRAR
===========================================

there was a need for something versatile // so why not?

GitHub: https://github.com/neuralpain
GitHub Repo: https://github.com/neuralpain/oneclickwinrar
Support me on Ko-fi: https://ko-fi.com/neuralpain

`oneclickrar.cmd`  - download, install/update and license WinRAR
`installrar.cmd`   - download and install WinRAR without licensing it (or
                     just update if already installed)
`licenserar.cmd`   - license WinRAR, if already installed
`unlicenserar.cmd` - remove WinRAR license, if already installed



FEATURES
--------

  - Install and license any available version of WinRAR for both 32-bit and
    64-bit architectures
  - Automatically downloads and installs the latest English WinRAR (64-bit)
    installer
  - Supports downloading specific versions of WinRAR and preserving the
    installers for future use
  - Status updates via Windows toast notifications
  - Create custom licenses for your personal use
  - Remove WinRAR licenses (for whatever reason)
  - Uninstall WinRAR


  [#] NOTE [#]

    `oneclickwinrar` will not overwrite existing licenses unless explicitly
    instructed to do so.



HOW TO USE
----------

  1. Extract the contents of the zip file to a directory of your choice
  2. Add a WinRAR executable to the directory, if necessary
  3. (Optional) Configure the script with specific data
  4. Run the script


  [*] IMPORTANT [*]

    * Remember to extract the `bin` folder with the script files. This is
      necessary for generating the license key.
    * You do not need to configure the script before running it. The script
      will automatically download and install the latest version of WinRAR.



CONFIGURATION
-------------

  The aim of this method of configuration is to provide a quick and easy way
  for anyone to enable extra functionality in the script while preserving
  portability. Essentially, one would only need to configure the script once
  and run it anywhere without the need for extra clicks or editing.

  The scripts can be configured to either add a custom license, install a
  specific version of WinRAR or a combination of both(with `oneclickwinrar.cmd`).

  There are six (6) parameters in the configuration process:

    `licensee`      - This is "you" or whatever name you want to use
    `license-type`  - The description of license that you want to install. This
                      is optional.
    `script-name`   – The name of the script file [`oneclickrar`, `licenserar`,
                      `installrar`] that you use to install and/or license WinRAR.
                      The script name is used for toggling switches in the script.
    `architecture`  - The architecture of the WinRAR executable (eg. x64, x32).
                      The architecture can be omitted for custom download/install
                      and will default to 64-bit.
    `version`       - The version of the WinRAR executable without any periods
                      `"."` (eg. 590, 701). This is optional.
    `tags`          - These are additional tags, usually found at the end of
                      the WinRAR executable name, used to describe the language
                      of the executable and whether or not it is a beta release.
                      This is optional.


  [*] IMPORTANT [*]

    The `tags` are in the pattern of `<beta+lang>`. Beta tags are normally `b1`,
    `b2`, etc. You can check out the [language tags list][language] to see the
    supported languages. Look at the example below for the 32-bit Russian beta of
    WinRAR 6.02.

      oneclickrar_x32_602_b1ru.cmd

    If there is no beta, you can just add the language tag like this config for
    the Japanese 64-bit version of WinRAR 7.00.

      installrar_x64_700_jp.cmd



  <!> WARNING <!>

    The `script-name` is the name of the script file [oneclickrar, licenserar,
    installrar] that you use to install and/or license WinRAR.

    DO NOT MODIFY THE `script-name` UNLESS YOU NEED TO OVERWRITE LICENSES OR
    SAVE DOWNLOADED INSTALLERS OR ENABLE SPECIAL FUNCTIONS.



NAMING PATTERNS
---------------

[#] NOTE [#]

  If you don't see a `.cmd` extension in the file name, DO NOT ADD IT. This
  just means that you have "Show file name extensions" disabled in Windows
  Explorer. No, you DO NOT need to enable it. Just continue customizing the
  script without adding the extension.



[+] install and license naming pattern (supported by oneclickrar.cmd)

    [licensee]_[license-type]_<script-name>_[architecture]_[version]_[tags].cmd

  Example:
    • oneclickrar_x32.cmd
    • oneclickrar_700.cmd
    • oneclickrar_x64_700.cmd
    • My Name_oneclickrar_ru.cmd
    • My Name_oneclickrar_x64_700.cmd
    • My Name_My License_oneclickrar_x32_sc.cmd


[+] licensing-only pattern (supported by licenserar.cmd, oneclickrar.cmd)

  When setting up custom licensing, you must only add information BEFORE the
  `script-name`.

    [licensee]_[license-type]_<script-name>.cmd

  Example:
    • My Name_licenserar.cmd
    • Company Name_Company License Type_licenserar.cmd


[+] install-only pattern (supported by installrar.cmd, oneclickrar.cmd)

  When setting up custom installation, you must only add information AFTER the
  `script-name`.

    <script-name>_[architecture]_[version]_[tags].cmd

  Example:
    • installrar_x32.cmd
    • installrar_700.cmd
    • installrar_x64_700.cmd
    • installrar_x64_700_ru.cmd



<#> CAUTION <#>

  Underscores "_" are primarily used for data separation and SHOULD NOT be
  used in license information or download data.



[*] IMPORTANT [*]

  * `installrar.cmd` is for installation only. It does not support licensing.
  * `licenserar.cmd` is for licensing only. It does not support installation.
  * Spaces are allowed within the `<licensee>` and `<license-type>` names.
  * The different data must be separated by an underscore.
  * The `<licensee>` and `<license-type>` will be displayed exactly as you type
    them.



[#] TIP [#]

  You can use as many underscores as you want. The example below is valid.

    My Name____My License__oneclickrar________x64_700_ru.cmd



OVERWRITING LICENSES
--------------------

  Overwriting is only supported by `oneclickrar.cmd` and `licenserar.cmd`.

  To enable overwriting licenses, you must edit the script's file name to have
  a hyphen "-" just before the "rar" so that it becomes "-rar". This is a very
  simple switch. Errors of any nature will bring shame upon the spring-loaded
  keys of your 1987 IBM Model M 1391401 White Label keyboard.

  Follow the examples below to see how it works.


    # very simple
    oneclick-rar.cmd


    # so simple
    Overwrite_ThisLicense_license-rar.cmd


    # more practical
    John Doe_Unlimited Lifetime License_oneclick-rar_x64_701.cmd



DOWNLOAD-ONLY MODE
------------------

  The functionality for saving downloads uses a similar approach to
  overwriting, providing a simple switch for configuration.

  Note: Saving downloads is only supported by `oneclickrar.cmd`.

  To enable download-only mode, you must edit the script's file name to have
  a hyphen `"-"` after `"one"` and before `"click"` so that it becomes
  `"one-click"`. This is another very simple switch. As with overwriting,
  errors of any nature will bring shame upon the spring-loaded blah blah blah.
  You get the point.

  Look at the example below.


    # very simple
    one-clickrar.cmd


  Installing WinRAR with download-only enabled
  --------------------------------------------

    When download-only mode is enabled, the script immediately exits upon
    completion of the download even if there are other configurations set for
    the script.

    To bypass this and allow for installation while download-only is enabled,
    you should also switch on overwriting which will override the download-only
    switch to both save the installer **AND** run the installation.


      # download-only with overwrite
      one-click-rar.cmd


    However, this move will of course overwrite the current installation of
    WinRAR (if any) with the custom or default settings so be sure to
    double-check before you run `oneclickrar`.


      # more practical
      Abigail Wilson_Pistachio License_one-click-rar_x64_624_fr.cmd



EXTRA STUFF
-----------

  Special function codes for `oneclickrar`
  ----------------------------------------

    `oneclickrar` supports enabling special functionality within the script by
    replacing the `i` in `click` with one of the codes below.

    - Code `0`: Uninstall WinRAR
    - Code `1`: Un-license WinRAR
    - Code `2`: Skip licensing and just install WinRAR
    - Code `3`: Skip installation and just license WinRAR


      # an example showing how to rename with the code

      oneclickrar.cmd
           └──────────┐
      Substitute the `i` here
           ┌──────────┘
      onecl█ckrar.cmd
           └─────┐
      with code `3` for example
           ┌─────┘
      onecl3ckrar.cmd
           └───────────── just like this.


  Uninstalling WinRAR
  -------------------

    Yes, `oneclickwinrar` supports uninstalling WinRAR.

    1. Uninstall with `oneclickrar`
    2. Uninstall with `unlicenserar` by editing the script name to be
       `un-licenserar.cmd`.



LICENSE
-------

`oneclickwinrar` is licensed under the BSD 2-Clause license.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

See the LICENSE file for more information.


This project makes use of the open-source software `winrar-keygen` developed by
@BitCookies and licensed under the MIT license.

See the /bin/winrar-keygen/LICENSE file for more information.



CHANGELOG
---------

0.13.0.713

  - OCWR can retrieve the latest version of WinRAR through either
      (a) scraping the "What's New" page on the webiste; or
      (b) probing the server with URLs for the subsequent iterative minor
          version updates up to the next major udpdate.
  - Other minor code improvements.

0.12.2.713

  - Update version list to include latest WinRAR 7.13.

0.12.1.712

  - Will now display the location of the installer after the download has been
    completed.
  - Fix: Corrected a false positive for too many arguments was detected when
    only the "download-only" flag was set.
  - Improve: Refactored the language parsing for null and english
  - Other minor bug fixes and code improvements.

0.12.0.712

  - New: Add interactive user prompts for handling ambiguous situations like
    re-installing, choosing between 32/64-bit installations, or overwriting
    licenses.
  - New: Add automatic downloading of the keygen executable if it is not
    found locally for custom license generation.
  - New: Add pre-download verification to check if a requested installer
    exists on the server before starting the download.
  - New: Add support for multiple download servers with an automatic retry
    mechanism to improve download reliability.
  - New: The script now detects and allows management of systems with both
    32-bit and 64-bit WinRAR installations.
  - Fix: Corrected an issue where the downloaded installer file was not
    always deleted after use.
  - Fix: Corrected a bug where the internal path to the license key file
    (`rarreg.key`) was incorrect.
  - Improve: Substantially refactored the script name parsing logic for
    better robustness and flexibility.
  - Improve: The user interface now includes an ASCII art title and
    color-coded console messages.
  - Improve: Expanded in-script documentation and added many new usage
    examples.

0.11.0.711

  - Fix download-only failing whenever a specific version of WinRAR is not
    provided.
  - Update default version to WinRAR 7.11.

0.10.0.710

  - Update default version to WinRAR 7.10.

0.9.0.701

  - New: Enable extra functionality through substitution of the `i` in `click`
    with a specific number code, e.g., `onecl0ckrar.cmd`, `one-cl3ck-rar.cmd`.
  - `oneclickrar` will now assume 64-bit if the `architecture` is omitted when
    downloading a specific version of WinRAR.
  - Add functionality for `oneclickrar` to license WinRAR without running an
    installation of the software.
  - Add functionality for `oneclickrar` to run the installation of WinRAR
    without licensing it afterwards.
  - Add support to uninstall WinRAR.
  - Minor code improvements.

0.8.0.701

  - Add support for older 32-bit WinRAR installers.
  - Add new download-only feature which allows for saving of installers
    downloaded by the script.
  - Minor bug fixes and code improvements.

0.7.0.701

  - Fix WinRAR version display error.
  - Improved script name parsing logic.
  - Fix annoying bug with variable scope in `licenserar.cmd`.
  - Improve error handling when downloading files that are not available on the
    server.
  - Improve toast notifications.
  - Other code improvements.

0.6.1.701

  - Fix very minor bug in licenserar.cmd affecting overwriting licenses.
  - Fix toast message in oneclickrar.cmd.

0.6.0.701

  - Fix downloading issue. "x86" was mistakenly used for downloading 32-bit
    versions of WinRAR. This has been fixed.
  - Add support for downloading without including a version number.
  - Fix function name error in installrar.cmd.
  - Provide installrar.cmd with admin by default.
  - Improve error handling for oneclickrar.cmd where WinRAR was installed but
    not licensed.
  - Add protection against overwriting existing licenses.
  - Add option to overwrite existing licenses.
  - Add unlicenserar.cmd to remove WinRAR licenses for whatever reason.
  - Minor bug fixes.

0.5.0.701

  - Allow users to generate custom licenses to activate WinRAR by modifying the
    script's file name.
  - Allow users to download any version of WinRAR by modifying the script's
    file name.

0.4.0.2407

  - Update WinRAR download version.
  - Update TLS security.
  - Add support for multiple languages.

0.3.0

  - Add error handling.

0.2.5

  - Remove unnecessary `$rarkey` variable from installrar.cmd.

0.2.4

  - Provide feedback if license is not installed.

0.2.3

  - Replace `$silent` variable with "/s".

0.2.2

  - Moved `$installer = (Get-Installer)` into the if statement
    `if ($null -eq (Get-Installer)) {...}`.

0.2.1

  - Fix licensing issue.

0.2.0

  - Add support for all versions of WinRAR.

0.1.0

  - Initial release.

                                       _         _                              
                   ___ ___ _ _ ___ ___| |___ ___|_|___                          
                  |   | -_| | |  _| .'| | . | .'| |   |                         
                  |_|_|___|___|_| |__,|_|  _|__,|_|_|_|                         
                                        |_|                                     
