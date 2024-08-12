<p align="center">
  <picture><img src="./assets/images/oneclickwinrar-header.jpg" alt="oneclickwinrar header"></picture>
</p>

Introducing **oneclickwinrar**—a streamlined set of scripts that installs and licenses WinRAR with a single click (or double). Perfect for quick setups, it eliminates manual steps, ensuring WinRAR is ready to use instantly. Ideal for both IT pros and everyday users.

```
there was a need for something versatile // so why not?
```

> [!NOTE]
> `oneclickwinrar` refers to this project and everything that comes with it. On the other hand, `oneclickrar.cmd` (notice there's no "win" in the name) is a script within the project. Don't mix them up.  

# What's included? (Click on the links to download)

### [oneclickrar.cmd](https://github.com/neuralpain/oneclickwinrar/releases/latest/download/oneclickrar.cmd) *(recommended for most users)*

The one click you need to rule them all. Download, install, update and license WinRAR, all in just one single click (or double). Yes, it's that simple.

### [installrar.cmd](https://github.com/neuralpain/oneclickwinrar/releases/latest/download/installrar.cmd)

Just need to install WinRAR or update if it's already installed? Here's a script for that. No need to download it yourself. Let `installrar` take care of that for you. Download and install WinRAR without licensing it.

### [licenserar.cmd](https://github.com/neuralpain/oneclickwinrar/releases/latest/download/licenserar.cmd)

C'mon, you've been using WinRAR unlicensed for years. Just [get a license](https://shop.win-rar.com/16/purl-shop-2183-1-n) and be done with that infinite 40-day trial. (You can also use this script to install a license that you purchased directly from WinRAR.)

### [unlicenserar.cmd](https://github.com/neuralpain/oneclickwinrar/releases/latest/download/unlicenserar.cmd)

A stitch in time saves nine. Return to that 40-day infinite trial period and relive the pain.

> [!TIP]
> Get the full package from the [releases page](https://github.com/neuralpain/oneclickwinrar/releases/latest). It includes everything you need for customization.
>
> Yes, customization. Read further down past the "features" and the "how to's" for the customization section. It might get a bit "technical".

## features

- Install and license almost any version of WinRAR
- Automatically downloads and installs the latest English WinRAR (64-bit) installer
- Supports downloading specific versions of WinRAR
- Create custom licenses for your personal use
- Remove WinRAR licenses (for whatever reason)

> [!NOTE]
> `oneclickwinrar` will not overwrite existing licenses unless explicitly told to do so.

## benefits

***<small>(courtesy of ChatGPT, refined by me)</small>***

- **Convenience** – Users can quickly and easily install and license WinRAR without navigating through multiple steps or settings and enhances the overall user experience by simplifying the process, making it more user-friendly and less daunting for those who may not be comfortable with manual installations. This is particularly useful for users who may not be tech-savvy.
- **Time-Saving** – The automation reduces the time required to manually download, install, and adding license information for WinRAR. This is beneficial for both individual users and IT departments managing multiple machines.
- **Consistency** – Ensures that WinRAR is installed and licensed in a consistent manner across multiple systems. This is particularly important in enterprise environments where uniformity is required.
- **Scalability** – Makes it easy to deploy WinRAR across a large number of machines, which is useful for businesses and organizations that need to ensure all users have access to the same software.
- **Remote Deployment** – Facilitates remote installation and licensing, which is particularly useful for IT administrators managing remote or distributed workforces.
- **Compliance** – Helps ensure that all installations of WinRAR are properly licensed, which is important for legal and compliance purposes.
- **Integration** – Can be integrated into larger deployment scripts or system setups, making it a seamless part of the overall software deployment process.
- **Customization** – Allows for customization by pre-configuring download and license information via editing the script name.

## limitations

- No ARM support
- No MacOS support
- No Linux support
- No support for 32-bit installers older than 611. These versions used a different "wrar" prefix to the version number.

# How to use

1. Download the latest release from the releases page (or use what you downloaded from above)
2. Extract the contents of the zip file to a directory of your choice, if necessary
3. Add a WinRAR executable to the directory, if necessary
4. (Optional) Customize and/or run the script you want to use

> [!IMPORTANT]
> Remember to extract the `bin` folder with the script files. This is necessary for generating your customized license key.

## customization

There are two types of customization:

  1. **Partial customization**, which is either custom licensing, or custom install
  2. **Complete customization**, which is both custom licensing and install

There are five (5) parts to the customization process:

- `licensee` – This is "you" or whatever name you want to use
- `license_type` – The description of license that you want to install
- `architecture` – The architecture of the WinRAR executable (x32 or x64)
- `version` – The version of the WinRAR executable without any periods `"."` (eg. 590, 701). **This is optional.**
- `tags` – These are additional tags, usually found at the end of the WinRAR executable name, used to describe the language of the executable and whether or not it is a beta release. **This is optional.**

> [!WARNING]
> The `script_name` is the name of the script file [oneclickrar, licenserar, installrar] that you use to install and/or license WinRAR. Do not modify the `script_name` unless you need to [overwrite licenses](#overwriting-licenses).

## naming patterns

> [!NOTE]
> If you don't see a `.cmd` extension in the file name, **do not add it**. This just means that you have `"Show file name extensions"` disabled in Windows Explorer. No, **you do not need to enable it**. Just continue customizing the script without adding the extension.

### complete naming pattern (supported by oneclickrar.cmd)

```
<licensee>_<license_type>_<script_name>_<architecture>_<version>_<tags>.cmd

Example: My Name_My License_oneclickrar_x64_700.cmd
```

### licensing-only pattern (supported by licenserar.cmd, oneclickrar.cmd)

When setting up custom licensing, you must only add information ***BEFORE*** the `script_name`.

```
<licensee>_<license_type>_<script_name>.cmd

Example: My Company_My Company License_licenserar.cmd
```

### install-only pattern (supported by installrar.cmd, oneclickrar.cmd)

When setting up custom install, you must only add information ***AFTER*** the `script_name`.

```
<script_name>_<architecture>_<version>_<tags>.cmd

Example: installrar_x64_700ru.cmd // Russian language
```

> [!CAUTION]
> Underscores `"_"` are primarily used for data separation and **should not** be used in license information or download data.

> [!IMPORTANT]
> * `installrar.cmd` is for installation only. It does not support custom licenses.
> * `licenserar.cmd` is for licensing only. It does not support custom install.
> * Spaces are allowed in the `licensee` and `license_type` names.
> * The different data must be separated by an underscore.
> * The `licensee` and `license_type` will be displayed exactly as you type them.
> * `unlicenserar.cmd` is for removing licenses only. It cannot be customized.

> [!TIP]
> You can use as many underscores as you want to separate the data within the file name, if it helps you read it better. The example below is valid.
> ```
> My Name____My License__oneclickrar________x64_700.cmd
> ```

## overwriting licenses

Information pertaining to overwriting licenses is in its own section because it's a bit different (not that much different) and there are some people out there in the world who may, for one reason or another, happen to miss it.

Overwriting is only supported by `oneclickrar.cmd` and `licenserar.cmd`.

To enable overwriting licenses, you must edit the script's file name to have a hyphen `"-"` just before the `"rar"` so that it becomes `"-rar"`. This is a very simple switch. Errors of any nature will bring shame upon the spring-loaded keys on your 1987 IBM Model M 1391401 White Label keyboard.

Follow the examples below to see how it works.

```
# very simple
oneclick-rar.cmd
```
```
# so simple
Overwrite_ThisLicense_license-rar.cmd
```
```
# more practical
John Doe_Unlimited Lifetime License_oneclick-rar_x64_701.cmd
```

# License

```
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
```

```
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
```
