<!-- Links -->
[stars]: https://github.com/latte-soft/maui/stargazers
[fork]: https://github.com/latte-soft/maui/fork
[latest-release]: https://github.com/latte-soft/maui/releases/latest
[license]: https://github.com/latte-soft/maui/blob/main/LICENSE.txt
[commits]: https://github.com/latte-soft/maui/commits

[roblox-marketplace]: https://www.roblox.com/library/12071720464
[discord]: https://latte.to/discord
[twitter]: https://twitter.com/lattesoftworks

<!-- Badges -->
[badges/stars]: https://img.shields.io/github/stars/latte-soft/maui?label=Stars&logo=GitHub
[badges/fork]: https://img.shields.io/github/forks/latte-soft/maui?label=Fork&logo=GitHub
[badges/latest-release]: https://img.shields.io/github/v/release/latte-soft/maui?label=Latest%20Release
[badges/last-modified]: https://img.shields.io/github/last-commit/latte-soft/maui?label=Last%20Modifed
[badges/license]: https://img.shields.io/github/license/latte-soft/maui?label=License

<!-- Social icons -->
[social/roblox-marketplace]: assets/repo/social_icons/roblox_dev.svg
[social/github]: assets/repo/social_icons/github.svg
[social/discord]: assets/repo/social_icons/discord-icon.svg
[social/twitter]: assets/repo/social_icons/twitter-icon.svg

<div align="center">

[<img width="250" src="assets/repo/MauiLogo-DarkMode.svg#gh-dark-mode-only" alt="Maui Logo (Dark Mode)" />](https://github.com/latte-soft/maui#gh-dark-mode-only)
[<img width="250" src="assets/repo/MauiLogo-LightMode.svg#gh-light-mode-only" alt="Maui Logo (Light Mode)" />](https://github.com/latte-soft/maui#gh-light-mode-only)

# Maui

Secure & Efficient Roblox Model/Script Bundler

[![Stars][badges/stars]][stars] [![Fork][badges/fork]][fork] [![Latest Release][badges/latest-release]][latest-release] [![Last Modified][badges/last-modified]][commits] [![License][badges/license]][license]

[![Get it on Roblox][social/roblox-marketplace]][roblox-marketplace] [![Get it on GitHub][social/github]][latest-release] [![Latte Softworks Discord][social/discord]][discord] [![@lattesoftworks on Twitter][social/twitter]][twitter]

</div>

___

## 🎉 About

Maui is a powerful, yet user-friendly and efficient script/model bundler for Roblox, greatly enhancing script development with modularity and allowing use of popular tools such as [Rojo](https://rojo.space), [Wally](https://wally.run), [Roblox-TS](https://roblox-ts.com), and many more!

**It's very general purpose.** You could even have an external workflow using industry-standard tooling like Git and VSCode, or even just use vanilla Roblox Studio if that's your preference! If it's built down to a model, Maui can bundle it all into an executable script.

<details open>
<summary>🌟 Basic Features</summary>
<br />
<ul>

* Bundling all scripts, classes, properties, attributes, and *any* scriptable Roblox DataTypes into one Lua/Luau script with [LuaEncode](https://github.com/regginator/LuaEncode)!
* Very simple and user friendly plugin UI.
* Extremely quick build times, with optimal output using an [rbxm](https://dom.rojo.space/binary)-like object structure for storage space, *and* runtime load speed optimizations.
* Clever global flattening in script closures, while still completely imitiating a normal individual script environment as expected.
* A very simple [runtime API](#the-maui-script-global).
* An easy, flexible [configuration format](#the-maui-project-format) for more advanced projects.

</ul>
</details>

## ⚙️ Installation

<details open>
<summary>(✨ RECOMMENDED) Roblox Marketplace</summary>
<br />
<ul>

You can purchase the plugin directly [here](https://www.roblox.com/library/12071720464). Remember, you *can* get the plugin for no cost directly from GitHub, but you are responsable for maintaining the build on your local machine. If you want to support us and recieve automatic updates on the plugin, you can use this option!

From there, just "Install" the plugin in Studio from Roblox like normal!

</ul>
</details>

<details closed>
<summary>Pre-Built Binaries from GitHub Releases</summary>
<br />
<ul>

Head over to the [latest release](https://github.com/latte-soft/maui/releases/lastest) page on the GitHub repository, and download whichever file suites best. ([`Maui.rbxm`](https://github.com/latte-soft/maui/releases/latest/download/Maui.rbxm) will load the quickest, and [`Maui.lua`](https://github.com/latte-soft/maui/releases/lastest/download/Maui.lua) is packed with Maui itself!)

If you don't know where your specific local plugins folder is, in Studio, goto the "Plugins" tab via the ribbon-bar, and on the left there should be a "Plugins Folder" button. Opening that will prompt open the local plugins folder, where you will be able to place the build in!

![Where the plugins folder is](assets/repo/usage/where_plugins_folder_is.png)

</ul>
</details>

<details closed>
<summary>Building from Source</summary>
<br />
<ul>

We provide an automated build script using [Lune](https://github.com/filiptibell/lune), which you can run from the base directory of the repository with `lune build`. You need everything in [`aftman.toml`](aftman.toml) installed and accessable from your `$PATH`, preferably with [Aftman](https://github.com/LPGhatguy/aftman).

The following instructions are just for building Maui as quickly as possible manually, in-case you can't use the Lune build script.

<sup><i>Keep in mind, you still need at least [Wally](https://wally.run) and [Rojo](https://rojo.space) installed to completely build the plugin.</i></sup>

* Clone the Repository

```txt
git clone https://github.com/latte-soft/maui.git && cd maui
```

* Install Packages w/ Wally

```txt
wally install
```

* Build Model w/ Rojo

```txt
rojo build -o Maui.rbxm
```

And you're done! You can place the built model file into your plugins folder

</ul>
</details>

## 🚀 Quick Start

<details open>
<summary>In a new/existing Studio place, go to the *"Plugins"* tab from the ribbon menu, and you'll see the plugin.</summary>
<br />
<ul>

<img width="190" src="assets/repo/usage/maui_in_plugins.png" alt="Maui in plugins tab" />

<img width="390" src="assets/repo/usage/initial_gui_widget.png" alt="What the widget's GUI looks like" />

</ul>
</details>

To bundle a model/project, just select an object, and click "Build" in the plugin's GUI. Due to LuaEncode's efficiency and optimization, Maui usually only takes a few *milliseconds* to bundle the output.

After the script is built, Maui will open the output in Studio's script editor, and Maui will store information logs from the build process in its internal console. From there, you're done! You can run the bundled output in a script utility, another script in your game, use it with Lua obfuscation, and anything else you'd need. It's 100% portable, and will work in almost *any* Roblox Lua/Luau environment.

For configuring how the codegen behaves at runtime, check out the built-in [project format](#the-maui-project-format). Also, by default, if you provide a `ModuleScript` named "MainModule" at the root of the model at build time, Maui will return the value from it with the exact same behavior as requiring a module by ID on Roblox.

## The `maui` Script Global

In all Maui script closures, a "`maui`" global is pushed into the environment. You could use it in a script like so:

```lua
if maui then -- Then the script is running under Maui's environment!
    print("Running on Maui v" .. maui.Version .. "!")
end
```

Here's the *current* API reference:

```lua
maui = {
    Version: string,
    Script: LuaSourceContainer,
    Shared: {[any]: any}
}
```

* ### Get Version

  ```lua
  maui.Version: string
  ```

  Returns a constant of the version of Maui the script was built with.

* ### Get Real Script Object

  ```lua
  maui.Script: LuaSourceContainer
  ```

  Returns the *real* `script` global from the closure that's currently running.

* ### Get Shared Environment Table

  ```lua
  maui.Shared: {[any]: any}
  ```

  Returns a "shared" table for ALL closures in a Maui-generated script, so you don't need to the real `_G` or `shared`.

## The `.maui` Project Format

<sup><i>Keep in mind, this is mainly meant for more advanced projects/modules you're bundling. It is <b>not</b> necessary for using Maui.</i></sup>

You can place a module named ".maui" under the model you're building, and Maui will expect the return to be a table of options. Here's a Lua template for this:

```lua
return {
    FormatVersion = 1, -- Isn't necessary in the project file, but just for future proofing the format incase we ever change anything

    -- All output options
    Output = {
        Directory = script.Parent, -- A string/function/instance returning a specific output path in the DataModel
        ScriptName = "MauiGeneratedScript", -- The actual name of the output script object, e.g. "SomeScript"
        ScriptType = "LocalScript", -- Accepts "LocalScript", "Script", and "ModuleScript"

        MinifyObject = true, -- If the object table itself in the output is to be minified
    },

    -- "Flags" to be respected at runtime
    Flags = {
        ContextualExecution = true, -- If client/server context should be checked at runtime, and ignores LuaSourceContainer.Disabled (e.g. LocalScripts only run on the client, Scripts only run on the server when this is true)
        ReturnMainModule = true, -- **If applicable**, return the contents of a "MainModule" named ModuleScript from the root of the model. This behaves exactly like Roblox's MainModule system
    },

    -- Property wl/bl overrides
    Properties = {
        Whitelist = {}, -- [ClassName] = {PropertyName, ...}
        Blacklist = {}, --  ^^^
    }
}
```

You can *also* use [Rojo's JSON module feature](https://rojo.space/docs/v7/sync-details/#json-modules) (if you're using Rojo) to store this module in JSON, which would obviously be a file named ".maui.json":

```json
{
    "FormatVersion": 1,

    "Output": {
        "Directory": "return script.Parent",
        "ScriptName": "MauiGeneratedScript",
        "ScriptType": "LocalScript",

        "MinifyTable": false,
        "UseMinifiedLoader": true
    },

    "Flags": {
        "ContextualExecution": false,
        "ReturnMainModule": true
    },

    "Properties": {
        "Whitelist": {},
        "Blacklist": {}
    }
}
```

Still keep in mind, you need to include this file in your `*.project.json` file, if you're using Rojo.

## 🤝 Contributing

*For now*, there really aren't any specific contribution instructions to follow. We're still working on our public Luau style-guide, so if you have an idea/implementation of something, show us your idea through an [issue](https://github.com/latte-soft/maui/issues) or [pull-request](https://github.com/latte-soft/maui/pulls)!

___

## 🏛️ License

This project, and all related files/documents, are licensed under the **MIT License**. You should have recieved a copy of [`LICENSE.txt`](LICENSE.txt) in this program. If not:

<details open>
<summary>MIT License</summary>
<br />
<ul>

```txt
MIT License

Copyright (c) 2022-2023 Latte Softworks <latte.to>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

</ul>
</details>

### Extras

* *README social link icons by [@csqrl](https://github.com/csqrl)*
