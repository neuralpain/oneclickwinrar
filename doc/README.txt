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
               '\/__//__/  \/_/\/_/\/_/\/_/\/ /\/_/\/_/\/_/\/ /  v0.6.0.701     


oneclickwinrar - install and license WinRAR
===========================================

there was a need for something versatile // so why not?

GitHub: https://github.com/neuralpain
GitHub Repo: https://github.com/neuralpain/oneclickwinrar
Support me on Ko-fi: https://ko-fi.com/neuralpain

`oneclickrar.cmd`  - download, install/update and license WinRAR
                     (recommended for most users)
`installrar.cmd`   - download and install WinRAR without licensing it (or
                     just update if already installed)
`licenserar.cmd`   - license WinRAR, if already installed
`unlicenserar.cmd` - remove WinRAR license, if already installed



FEATURES
--------

  - Install and license ANY version of WinRAR
  - Automatically downloads and installs the latest English WinRAR (64-bit) 
    installer
  - Supports downloading and installing WinRAR through modification of the 
    script name
  - Create custom licenses for your personal use
  - Remove WinRAR licenses (for whatever reason)


[#] NOTE [#]

  `oneclickwinrar` will not overwrite existing licenses unless explicitly told 
  to do so.



HOW TO USE
----------

  1. Download the latest release from the releases page
  2. Extract the contents of the zip file to a directory of your choice
  3. Add a WinRAR executable to the directory, if necessary
  4. Customize and/or run the script you want to use


[*] IMPORTANT [*]

  * Remember to extract the `bin` folder with the script files. This is
    necessary for generating the license key.
  * It is not necessary to customize the script before running it. The script
    will automatically download and install the latest version if WinRAR.



CUSTOMIZATION
-------------

There are two types of customization:

  1. Partial customization   which is either custom licensing, or custom
                             install
  2. Complete customization  which is both custom licensing and install

There are five (5) parts to the customization process:

  - `licensee`       This is "you" or whatever name you want to use
  - `license_type`   The description of license that you want to install
  - `architecture`   The architecture of the WinRAR executable (eg. x64, x32)
  - `version`        The version of the WinRAR executable without any periods
                     `"."` (eg. 590, 701). This is optional.
  - `tags`           These are additional tags, usually
                     found at the end of the WinRAR executable name, used to
                     describe the language of the executable and whether or
                     not it is a beta release. This is optional.


<!> WARNING <!>

  The `script_name` is the name of the script file [oneclickrar, licenserar,
  installrar] that you use to install and/or license WinRAR.

  DO NOT CHANGE THE `script_name` unless you want to overwrite licenses.



NAMING PATTERNS
---------------

[#] NOTE [#]

  If you don't see a `.cmd` extension in the file name, DO NOT ADD IT. This 
  just means that you have "Show file name extensions" disabled in Windows 
  Explorer. No, you DO NOT need to enable it. Just continue customizing the 
  script without adding the extension.



[+] complete naming pattern (supported by oneclickrar.cmd)

    <licensee>_<license_type>_<script_name>_<architecture>_<version>_<tags>.cmd

  Example: My Name_My License_oneclickrar_x64_700.cmd


[+] licensing-only pattern (supported by licenserar.cmd, oneclickrar.cmd)
  
  When setting up custom licensing, you must only add information BEFORE the
  `script_name`.

    <licensee>_<license_type>_<script_name>.cmd

  Example: My Company_My Company License_licenserar.cmd


[+] downloading-only pattern (supported by installrar.cmd, oneclickrar.cmd)

  When setting up custom downloading, you must only add information AFTER the
  `script_name`.

    <script_name>_<architecture>_<version>_<tags>.cmd

  Example: installrar_x64_700.cmd



<#> CAUTION <#>

  Underscores "_" are primarily used for data separation and SHOULD NOT be
  used in license information or download data.



[*] IMPORTANT [*]

  * `installrar.cmd` is for installation only. It does not support custom
    licenses.
  * `licenserar.cmd` is for licensing only. It does not support custom
    install.
  * Spaces are allowed in the `licensee` and `license_type` names.
  * The different data must be separated by an underscore.
  * The `licensee` and `license_type` will be displayed exactly as you type
    them.
  * `unlicenserar.cmd` is for removing licenses only. It cannot be customized.



[#] TIP [#]

  You can use as many underscores as you want. The example below is valid.

    My Name____My License__oneclickrar________x64_601.cmd



OVERWRITING LICENSES
--------------------

  Overwriting is only supported by `oneclickrar.cmd` and `licenserar.cmd`.

  To enable overwriting licenses, you must edit the script's file name to have 
  a hyphen "-" just before the "rar" so that it becomes "-rar". This is a very 
  simple switch. Errors of any nature will bring shame upon the spring-loaded 
  keys on your 1987 IBM Model M 1391401 White Label keyboard.

  Follow the examples below to see how it works.


    # very simple
    oneclick-rar.cmd


    # so simple
    Overwrite_ThisLicense_license-rar.cmd


    # more practical
    John Doe_Unlimited Lifetime License_oneclick-rar_x64_701.cmd



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

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

See the /bin/winrar-keygen/LICENSE file for more information.



CHANGELOG
---------

0.6.0.701

  - Fix downloading issue. "x86" was mistakenly used for downloading 32-bit
    versions of WinRAR. This has been fixed.
  - Add support for downloading without including a version number
  - Fixed function name error in installrar.cmd
  - Provide installrar.cmd with admin by default
  - Improve error handling for oneclickrar.cmd
  - Add protection against overwriting existing licenses
  - Add option to overwrite existing licenses
  - Add unlicenserar.cmd to remove WinRAR licenses for whatever reason
  - Minor bug fixes

0.5.0.701

  - Allow users to generate custom licenses to activate WinRAR by modifying the
    script's file name
  - Allow users to download any version of WinRAR by modifying the script's
    file name
  
0.4.0.2407

  - Update WinRAR download version
  - Update TLS security
  - Add support for multiple languages
  
0.3.0

  - Add error handling

0.2.5

  - Remove unnecessary `$rarkey` variable from installrar.cmd

0.2.4

  - Provide feedback if license is not installed

0.2.3

  - Replace `$silent` variable with "/s"

0.2.2

  - Moved `$installer = (Get-Installer)` into the if statement 
    `if ($null -eq (Get-Installer)) {`

0.2.1

  - Fix licensing issue

0.2.0

  - Add support for all versions of WinRAR

0.1.0

  - Initial release

                                       _         _                              
                   ___ ___ _ _ ___ ___| |___ ___|_|___                          
                  |   | -_| | |  _| .'| | . | .'| |   |                         
                  |_|_|___|___|_| |__,|_|  _|__,|_|_|_|                         
                                        |_|                                     
                                                       
                                                       
