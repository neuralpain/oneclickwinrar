> [!TIP]
> RARLAB® has released the 2nd beta version of the latest English WinRAR 7.10 for testing on 64-bit systems! Use one of the configurations below to install and test it out. 🚀
>
> ```
> oneclickrar_x64_710_b2.cmd
> ```
>
> ```
> installrar_x64_710_b2.cmd
> ```

<p align="center">
  <picture><img src="./assets/images/oneclickwinrar-header.jpg" alt="oneclickwinrar header"></picture>
</p>

Introducing **oneclickwinrar**—a streamlined set of scripts that installs and licenses WinRAR with a single click (or double). Perfect for quick setups, it eliminates manual steps, ensuring WinRAR is ready to use instantly. Ideal for both IT pros and everyday users.

```
there was a need for something versatile // so why not?
```

> [!NOTE]
> The name `oneclickwinrar` refers to this project and everything that comes with it. On the other hand, `oneclickrar.cmd` (notice there's no "win" in the name) is a script within the project. Don't mix them up.

# What's included? (Click on the links to download)

### [oneclickrar.cmd][oneclick] _(recommended for most users)_

The one click you need to rule them all. Download, install, update and license WinRAR, all in just one single click (or double). Yes, it's that simple.

### [installrar.cmd][install]

Just need to install WinRAR or update if it's already installed? Here's a script for that. No need to download it yourself. Let `installrar` take care of that for you. Download and install WinRAR without licensing it.

### [licenserar.cmd][license]

C'mon, you've been using WinRAR unlicensed for years. Just [get a license](https://shop.win-rar.com/16/purl-shop-2183-1-n) and be done with that infinite 40-day trial. (You can also use this script to install a license that you purchased directly from WinRAR.)

### [unlicenserar.cmd][unlicense]

A stitch in time saves nine. Return to that 40-day infinite trial period and relive the pain.

> [!TIP]
> Get the full package from the [releases page][release]. It includes everything you need for customization.
>
> Yes, [customization](#customization). Read further down past the "features" and the "how to's" for the customization section. It might get a bit "technical".

## features

- Install and license any available version of WinRAR for both 32-bit and 64-bit architectures
- Automatically download and install the latest English WinRAR (64-bit) installer (at time of release)
- Optionally download a specific version of WinRAR and/or preserve the installer for future installations
  - `oneclickwinrar` deletes download cache by default
- Status updates via Windows toast notifications
  - Click on the notifications when they appear (with or without a visible button) for more more information
- Create custom licenses for your personal use
- Remove WinRAR licenses (for whatever reason)

### script comparison table

|               | oneclickrar | installrar | licenserar | unlicenserar |
| ------------- | :---------: | :--------: | :--------: | :----------: |
| installation  |      ✓      |     ✓      |     ✗      |      ✗       |
| licensing     |      ✓      |     ✗      |     ✓      |      ✗       |
| overwriting   |      ✓      |     ✗      |     ✓      |      ✗       |
| download-only |      ✓      |     ✗      |     ✗      |      ✗       |
| un-licensing  |      ✗      |     ✗      |     ✗      |      ✓       |
| uninstall     |      ✗      |     ✗      |     ✗      |      ✗       |

> [!NOTE]
> `oneclickwinrar` will not overwrite existing licenses unless explicitly instructed to do so.

---

### development plans

- [x] License overwriting
- [x] Support for older 32-bit installers with `wrar` name
- [x] Download-only mode using a switch feature similar to overwriting
- [ ] Allow script to assume 64-bit if no `architecture` is specified with a custom `version`
- [ ] Allow `oneclickrar` and `installrar` to uninstall WinRAR
- [ ] Allow `oneclickrar` to skip licensing
- [ ] Allow future customization through modification of the `i` in `click` to a specific number, e.g., `onecl0ckrar.cmd`, `one-cl3ck-rar.cmd`.

### other plans

- [ ] Rewrite the benefits section below
- [x] Create a list of language codes supported by WinRAR
- [ ] Create a list of all available versions of WinRAR and the years of release
- [ ] Place the "plans" section in a more suitable area

---

## benefits

~~**_<small>(courtesy of ChatGPT, refined by me)</small>_**~~

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
- ~~No support for 32-bit installers older than 611. These versions used a different "wrar" prefix to the version number.~~ → Added support in `v0.8.0`.

# How to use

### basic usage

1. Download the latest release of `oneclickwinrar` from the releases page
2. Extract the contents of the zip file to a directory of your choice, if necessary
3. Add a WinRAR executable to the directory, if necessary
4. Run the script

### advanced usage

Follow basic usage 1-3, then read through the customization section to add custom licenses, downloads and enable different features.

> [!IMPORTANT]
> Remember to extract the `bin` folder together with the script. This is necessary for generating your customized license key.

# Customization

There are two (2) types of customization:

1. **Partial customization** i.e. custom licensing, custom install or custom download
2. **Complete customization** i.e. both custom licensing and installation

There are five (6) parts to the customization process:

1. `licensee` – This is "you" or whatever name you want to use
2. `license-type` – The description of license that you want to install
3. `script-name` – The name of the script file [`oneclickrar`, `licenserar`, `installrar`] that you use to install and/or license WinRAR. The script name is used for toggling switches in the script.
4. `architecture` – The architecture of the WinRAR executable (x32 or x64)
5. `version` – The version of the WinRAR executable without any periods `"."` (eg. 590, 701). **This is optional.**
6. `tags` – These are additional tags, usually found at the end of the WinRAR executable name, used to describe the language of the executable and whether or not it is a beta release. **This is optional.**

> [!IMPORTANT]
> The `tags` are in the pattern of `<beta+lang>`. Beta tags are normally `b1`, `b2`, etc. You can check out the [language tags list][language] to see the supported languages. Look at the example below for the 32-bit Russian beta of WinRAR 6.02.
>
> ```
> oneclickrar_x32_602_b1ru.cmd
> ```
>
> If there is no beta, you can just add the language tag like this config for the Japanese 64-bit version of WinRAR 7.00.
>
> ```
> oneclickrar_x64_700_jp.cmd
> ```

> [!WARNING]
> Do not modify the `script-name` unless you need to [overwrite licenses](#overwriting-licenses) or [save download cache](#download-only-mode).

## naming patterns

> [!NOTE]
> If you don't see a `.cmd` extension in the file name, **do not add it**. This just means that you have `"Show file name extensions"` disabled in Windows Explorer. No, **you do not need to enable it**. Just continue customizing the script without adding the extension.

### complete naming pattern (supported by oneclickrar.cmd)

```
<licensee>_<license-type>_<script-name>_<architecture>_<version>_<tags>.cmd

Example: My Name_My License_oneclickrar_x64_700.cmd
```

### licensing-only pattern (supported by licenserar.cmd, oneclickrar.cmd)

When setting up custom licensing, you must only add information **_BEFORE_** the `script-name`.

```
<licensee>_<license-type>_<script-name>.cmd

Example: My Company_My Company License_licenserar.cmd
```

### install-only pattern (supported by installrar.cmd, oneclickrar.cmd)

When setting up custom installation, you must only add information **_AFTER_** the `script-name`.

```
<script-name>_<architecture>_<version>_<tags>.cmd

Example: installrar_x64_700_ru.cmd // Russian language
```

> [!CAUTION]
> Underscores `"_"` are primarily used for data separation and **should not** be used in license information or download data.

> [!IMPORTANT]
>
> - `installrar.cmd` is for installation only. It does not support licensing.
> - `licenserar.cmd` is for licensing only. It does not support installation.
> - Spaces are allowed within the `licensee` and `license-type` names.
> - The different data must be separated by an underscore.
> - The `licensee` and `license-type` will be displayed exactly as you type them.
> - `unlicenserar.cmd` is for removing licenses only. It cannot be customized.

> [!TIP]
> You can use as many underscores as you want to separate the data within the file name, if it helps you read it better. The example below is valid.
>
> ```
> My Name____My License__oneclickrar________x64_700_ru.cmd
> ```

# Overwriting licenses

Information pertaining to overwriting licenses is in its own section because it's a bit different (not that much different) and there are some people out there in the world who may, for one reason or another, happen to miss it.

Note: Overwriting is only supported by `oneclickrar.cmd` and `licenserar.cmd`.

To enable overwriting licenses, you must edit the script's file name to have a hyphen `"-"` just before the `"rar"` so that it becomes `"-rar"`. This is a very simple switch. Errors of any nature will bring shame upon the spring-loaded keys of your 1987 IBM Model M 1391401 White Label keyboard.

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

# Download-only mode

The functionality for saving downloads uses a similar approach to overwriting, providing a simple switch for configuration.

Note: Saving downloads is only supported by `oneclickrar.cmd`.

To enable download-only mode, you must edit the script's file name to have a hyphen `"-"` after `"one"` and before `"click"` so that it becomes `"one-click"`. This is another very simple switch. As with overwriting, errors of any nature will bring shame upon the spring-loaded _blah blah blah_. You get the point.

Look at the example below.

```
# very simple
one-clickrar.cmd
```

### installing WinRAR with download-only enabled

When download-only mode is enabled, the script immediately exits upon completion of the download even if there are other customizations set for the script.

To bypass this and allow for installation while download-only is enabled, you should also switch on overwriting which will override the download-only switch to both save the installer **AND** run the installation.

```
# download-only with overwrite
one-click-rar.cmd
```

However, this move will of course overwrite the current installation of WinRAR (if any) with the custom or default settings so be sure to double-check before you run `oneclickrar`.

```
# more practical
Abigail Wilson_Pistachio License_one-click-rar_x64_624_fr.cmd
```

###### _A full customization of oneclickrar should look incomprehensible to the average person. If your customization looks incomprehensible, then you're an average person. Ironic, right?_

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

[release]: https://github.com/neuralpain/oneclickwinrar/releases/latest
[oneclick]: https://github.com/neuralpain/oneclickwinrar/releases/latest/download/oneclickrar.cmd
[install]: https://github.com/neuralpain/oneclickwinrar/releases/latest/download/installrar.cmd
[license]: https://github.com/neuralpain/oneclickwinrar/releases/latest/download/licenserar.cmd
[unlicense]: https://github.com/neuralpain/oneclickwinrar/releases/latest/download/unlicenserar.cmd
[language]: https://github.com/neuralpain/oneclickwinrar/wiki#localized-winrar-versions