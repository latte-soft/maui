<div align="center">
    <!-- Logo -->
    <a href="https://github.com/latte-soft/maui#gh-dark-mode-only">
        <img width="250" src="assets/MauiLogo-DarkMode.svg#gh-dark-mode-only" alt="Maui Logo (Dark Mode)" />
    </a>
    <a href="https://github.com/latte-soft/maui#gh-light-mode-only">
        <img width="250" src="assets/MauiLogo-LightMode.svg#gh-light-mode-only" alt="Maui Logo (Light Mode)" />
    </a>
    <!-- Title/Desc -->
    <h1>Maui</h1>
    <p>Roblox Studio Plugin for Packing Modules as Executable Luau Scripts</p>
    <p>
        <!-- Direct links -->
        <!-- Roblox marketplace -->
        <a href="https://www.roblox.com/library/12071720464">
            <img src="repo/social_icons/roblox_dev.svg" alt="Roblox Marketplace" />
        </a>
        <!-- GitHub releases -->
        <a href="https://github.com/latte-soft/maui/releases">
            <img src="repo/social_icons/github.svg" alt="GitHub Releases" />
        </a>
        <!-- Latte Discord -->
        <a href="https://latte.to/invite">
            <img src="repo/social_icons/discord-icon.svg" alt="Latte Softworks Discord" />
        </a>
        <!-- Latte Twitter -->
        <a href="https://twitter.com/lattesoftworks">
            <img src="repo/social_icons/twitter-icon.svg" alt="Latte Softworks Discord" />
        </a>
    </p>
    <p>
        <!-- PROJECT INFO START -->
        <!-- Repo stars -->
        <a href="https://github.com/latte-soft/maui/stargazers">
            <img src="https://img.shields.io/github/stars/latte-soft/maui?label=Stars&logo=GitHub" alt="Repo Stars" />
        </a>
        <!-- Repo forks -->
        <a href="https://github.com/latte-soft/maui/fork">
            <img src="https://img.shields.io/github/forks/latte-soft/maui?label=Fork&logo=GitHub" alt="Repo Forks" />
        </a>
        <!-- Latest release -->
        <a href="https://github.com/latte-soft/maui/releases/latest">
            <img src="https://img.shields.io/github/v/release/latte-soft/maui?label=Latest%20Release" alt="Latest Release" />
        </a>
        <!-- License info -->
        <a href="https://github.com/latte-soft/maui/blob/master/LICENSE.txt">
            <img src="https://img.shields.io/github/license/latte-soft/maui?label=License" alt="License" />
        </a>
        <!-- Last modified (latest commit) -->
        <a href="https://github.com/latte-soft/maui/commits">
            <img src="https://img.shields.io/github/last-commit/latte-soft/maui?label=Last%20Modifed" alt="Last Modified" />
        </a>
    </p>
</div>

___

## About

Put short, Maui is the full idea of Roblox model/object serialization **and** script packing put together. This allows script developers to use any of the tooling or libraries they wish! You could use a workflow with [VSCode](https://code.visualstudio.com), [Aftman](https://github.com/LPGhatguy/aftman), [Rojo](https://rojo.space), [Wally](https://wally.run), [Roblox-TS](https://roblox-ts.com), [Tarmac](https://github.com/Roblox/tarmac), [Darklua](https://darklua.com), etc.. Or just good ol' Roblox Studio! If it's built down to a Roblox model, you can build it into a script with Maui.

It's very general purpose, and will pack almost any model you throw at it. Any class, any property, any attribute, and *any* Lua DataType. As long as it's configured properly in the API dump and is a Lua-accessable DataType, it'll build!

Maui is built with [LuaEncode](https://github.com/regginator/LuaEncode), another general-purpose project of mine that was a direct component of this. It will handle **any** Lua/Roblox-Lua DataType, and even supports vanilla Lua 5.1! If it weren't for making LuaEncode, Maui wouldn't be possible.

### **Also..**

**The first thing you may be wondering if you clicked on the *"Get it on Roblox"* button before reading this** is probably something along the lines of **"Why is this a paid plugin?"**. Well, it *is* and it *isn't*. Let me explain.

The plugin, and **all** of its source code, will **always** be 100% free (as-in freedom) & open source, under the GNU LGPLv3 License. You can download & build from source on the [GitHub repository](https://github.com/latte-soft/maui) (if you're worried about security or whatnot), or install a pre-built version directly from the [releases page](https://github.com/latte-soft/maui/releases). We *also* provide the plugin on Roblox's Developer Marketplace for ~250 Robux, if you want to support us, or just want automatic updates. With a self/pre-built version of the plugin, you're responsible for keeping it up-to-date in your plugins folder.

___

## Why the Name?

The name of this project was originally going to be "Eclipse", however, it turned out to be a *very* generic and overused name, used by multiple other Lua (Roblox) projects. ("Lua" means "Moon", yeah..) [Roblox's built-in scripting language](https://luau-lang.org) is named "Luau", which is a type of [traditional party/feast](https://en.wikipedia.org/wiki/L%C5%AB%CA%BBau) in Hawaiian culture. ["Maui"](https://en.wikipedia.org/wiki/Maui) is one of the largest islands in Hawaii, with [Luau parties throughout the year](https://mauiluau.com). Hence, a non-generic name!

___

## Installation

* Installation via Roblox Marketplace

    You can purchase the plugin directly [here](https://www.roblox.com/library/12071720464). Remember, you *can* get the plugin for free directly from GitHub, but you are responsable for maintaining the build on your local machine.

    From there, just "Install" the plugin in Studio from Roblox like normal!

* Installation via GitHub Releases

    Goto the [latest release](https://github.com/latte-soft/maui/releases/lastest) on the GitHub repository, and download whichever file suites best. (`*.rbxm` is faster to load, and `*.rbxmx` is more readable.)

    Do note, pre-built versions of Maui are always minified with [Darklua](https://darklua.com), a Lua formatter. It is **not** obfuscation, just minification.

    If you don't know where your specific local-plugins folder is, in Studio, goto the "Plugins" tab via the ribbon-bar, and on the left there should be a "Plugins Folder" button, opening that will prompt the local plugins folder, where you will place the plugin in.

    ![Where the plugins folder is](repo/usage/where_plugins_folder_is.png)

* Building from Source

    We provide a [`build.sh`](build.sh) script, however it will only work with a POSIX-compliant shell. You need everything in [`aftman.toml`](aftman.toml) installed, preferably with [Aftman](https://github.com/LPGhatguy/aftman).

    The following instructions are just for building Maui as quickly as possible, in-case you can't use `build.sh`.

  * Clone the Repository (**Recursively!** We have [submodules](submodules) in use)

    ```txt
    git clone https://github.com/latte-soft/maui.git --recursive && cd maui
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

___

## Usage

In a new/existing Studio place, go to the *"Plugins"* tab from the ribbon-menu, and you'll see a button similar to this:

<img src="repo/usage/maui_in_plugins.png" alt="Maui in plugins tab" />

Upon toggle, you should automatically see the widget, which from there has more instructions in the console! It is *always* completely synced with **your** Studio's color palette theme, with Fusion components similar to Studio's look & feel.

<img width="420" src="repo/usage/initial_gui_widget.png" alt="What the widget's GUI looks like" />

From there, just select an object, and click "Build"! Due to LuaEncode's EXTREMELY fast speeds and optimization, Maui usually only takes a few *milliseconds* to create the output.

After the script is built, Maui should open the output script's editor window, and Maui will store information logs in the internal console.

<img width="600" src="repo/usage/built_script_example.png" alt="Example built-script output" />

<img width="450" src="repo/usage/widget_gui_console.png" alt="Widget gui console output" />

From there, you're done! You can run it in a script utility, another script, place it into obfuscation, etc.. It's 100% portable, and will work in almost *any* Roblox environment!

##### *This is a simple test-script for using Fusion with an exploit, you can see the source [here](tests/HelloFusion), and example output [here](examples/MauiFusionDemo_2023-01-06_13-24-23.lua)*

<img width="775" src="repo/usage/example_script_execution.png" alt="Example of script being used" />

___

## The `.maui` Project Format

##### *This is really meant for more advanced projects/modules you're packing, and right now there really isn't much outside of minification options.*

You can place a module named ".maui" under the model you're building, and Maui will expect the return to be a table of options. Here's a Lua template for this:

```lua
return {
    FormatVersion = 1, -- Isn't necessary in the project file, but just for future proofing the format incase we ever change anything
    -- All output options
    Output = {
        MinifyTable = true, -- If the codegen table itself (made from LuaEncode) is to be minified
        UseMinifiedLoader" = true -- Use the pre-minified LoadModule script in the codegen, which is always predefined and not useful for debugging
    }
}
```

You can *also* use [Rojo's JSON module feature](https://rojo.space/docs/v7/sync-details/#json-modules) (if you're using Rojo) to store this module in JSON, which would obviously be a file named ".maui.json":

```json
{
    "FormatVersion": 1,
    "Output": {
        "MinifyTable": true,
        "UseMinifiedLoader": true
    }
}
```

Still keep in mind, you need to include this file in your `*.project.json` file, if you're using Rojo.

___

## Contributing

*For now*, there really isn't any specific contribution instructions to follow. We're still working on our public Luau style-guide, so if you have an idea/implementation of something, show us your idea through an [issue](https://github.com/latte-soft/maui/issues) or [pull-request](https://github.com/latte-soft/maui/pulls)!

___

## License

This project, and all related files/documents, are licensed under the **GNU Lesser General Public License Version 3 (LGPLv3)**. You should have recieved a copy of [`LICENSE.txt`](LICENSE.txt) in this program, and you can visit here for more information: <https://www.gnu.org/licenses/lgpl-3.0.txt>

```txt
Maui | Copyright (c) 2022-2023 Latte Softworks <latte.to>
```

*README social link icons by [@csqrl](https://github.com/csqrl)*
