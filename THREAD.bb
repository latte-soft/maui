[color=#bdc3c7][font="Verdana"][align=center][url=https://github.com/latte-soft/maui][img=200x200]https://cdn.discordapp.com/attachments/1060751075415687178/1060753274350866442/MauiLogo-DarkMode.svg[/img][/url]
[size=xx-large][b]Maui — By Latte Softworks[/b][/size]
[size=large]Roblox Studio Plugin for Packing Modules as Executable Luau Scripts[/size]

[url=https://www.roblox.com/library/12071720464/Maui-Module-Packing-Serialization][img]https://cdn.discordapp.com/attachments/1060751075415687178/1060769983266836490/roblox_dev.svg[/img][/url] [url=https://github.com/latte-soft/maui/releases][img]https://cdn.discordapp.com/attachments/1060751075415687178/1060769982948048976/github.svg[/img][/url] [url=https://latte.to/invite][img]https://cdn.discordapp.com/attachments/1060751075415687178/1060769982612508753/discord-icon.svg[/img] [/url] [url=https://twitter.com/lattesoftworks][img]https://cdn.discordapp.com/attachments/1060751075415687178/1060769983560421416/twitter-icon.svg[/img][/url]

[hr][/align]

[size=x-small][i]You can skip reading this if you want to..[/i][/size]
[size=x-large][b]Preface[/b][/size]
Ever since the very simple beginnings of script development on this platform, we've all followed a fairly similar, basic way of writing and distributing scripts as a whole. We've had minor changes over the years with things like more complex obfuscation and auth systems, but for the most part, it's still quite the same overall; write everything in one script, and distribute. For tools/libraries made by script devs, this often isn't very organized, or [i]secure[/i] for that matter.

There have been fairly [i]similar[/i] solutions to these issues in the past like [url=https://v3rmillion.net/showthread.php?tid=1162252]"luapack"[/url] and [url=https://github.com/richie0866/rbxm-suite]"rbxm-suite"[/url], however, they usually only solved part of a problem, and either worked against the Roblox environment, or were just too impractical/had too many issues in production.

While the previous way of doing things is not necessarily [i]bad[/i], and can actually be quite useful for small/simple projects, it's not always efficent for proper code organization or development in general. These days, we also have MANY awesome, professional tools created by Roblox's OSS community like [url=https://rojo.space]Rojo[/url] and [url=https://wally.run]Wally[/url] [size=xx-small]sorry, wally[/size], and even libraries such as [url=https://github.com/Roblox/roact]React[/url], [url=https://github.com/Elttob/Fusion]Fusion[/url], and [url=https://github.com/evaera/roblox-lua-promise]Promise[/url].

[size=small][i]Please read [b]this[/b], though[/i][/size]
[size=x-large][b]Also..[/b][/size]
[b]The first thing you may be wondering if you clicked on the [i]"Get it on Roblox"[/i] button before reading this[/b] is probably something along the lines of [b]"Why is this a paid plugin?"[/b]. Well, it [i]is[/i] and it [i]isn't[/i]. Let me explain.

The plugin, and [b]all[/b] of its source code, will [b]always[/b] be 100% free (as-in freedom) & open source, under the GNU LGPLv3 License. You can download & build from source on the [url=https://github.com/latte-soft/maui]GitHub repository[/url] (if you're worried about security or whatnot), or install a pre-built version directly from the [url=https://github.com/latte-soft/maui/releases]releases page[/url]. We [i]also[/i] provide the plugin on Roblox's Developer Marketplace for ~250 Robux, if you want to support us, or just want automatic updates. With a self/pre-built version of the plugin, you're responsible for keeping it up-to-date in your plugins folder.

[hr]

[size=x-large][b]Ok.. So What [i]is[/i] Maui?[/b][/size]
Put short, Maui is the full idea of Roblox model/object serialization [b]and[/b] script packing put together. This allows script developers to use any of the tooling or libraries they wish! You could use a workflow with [url=https://code.visualstudio.com/]VSCode[/url], [url=https://github.com/LPGhatguy/aftman]Aftman[/url], [url=https://rojo.space]Rojo[/url], [url=https://wally.run]Wally[/url], [url=https://roblox-ts.com]Roblox-TS[/url], [url=https://github.com/Roblox/tarmac]Tarmac[/url], [url=https://darklua.com]Darklua[/url], etc.. Or just good ol' Roblox Studio! If it's built down to a Roblox model, you can build it into a script with Maui.

It's very general purpose, and will pack almost any model you throw at it. Any class, any property, any attribute, and [i]any[/i] Lua DataType. As long as it's configured properly in the API dump and is a Lua-accessable DataType, it'll build!

Maui is built with [url=https://github.com/regginator/LuaEncode]LuaEncode[/url], another general-purpose project of mine that was a direct component of this. It will handle [b]any[/b] Lua/Roblox-Lua DataType, and even supports vanilla Lua 5.1! If it weren't for making LuaEncode, Maui wouldn't be possible.

[size=x-large][b]Why the Name?[/b][/size]
The name of this project was originally going to be "Eclipse", however, it turned out to be a [i]very[/i] generic and overused name, used by multiple other Lua (Roblox) projects. ("Lua" means "Moon", yeah..) [url=https://luau-lang.org]Roblox's built-in scripting language[/url] is named "Luau", which is a type of [url=https://en.wikipedia.org/wiki/L%C5%AB%CA%BBau]traditional party/feast[/url] in Hawaiian culture. [url=https://en.wikipedia.org/wiki/Mau]"Maui"[/url] is one of the largest islands in Hawaii, with [url=https://mauiluau.com]Luau parties throughout the year[/url]. Hence, a non-generic name!

[hr]
[size=x-large][b]Installation & Getting Started[/b][/size]

[spoiler="Installation via Roblox Marketplace"]
You can purchase the plugin directly [url=https://www.roblox.com/library/12071720464]here[/url]. Remember, you [i]can[/i] get the plugin for free directly from GitHub, but you are responsable for maintaining the build on your local machine.

From there, just "Install" the plugin in Studio from Roblox!
[/spoiler]

[spoiler="Installation via GitHub Releases"]
Goto the [url=https://github.com/latte-soft/maui/releases/lastest]latest release[/url] on the GitHub repository, and download whichever file suites best. ([font=Courier]*.rbxm[/font] is faster to load, and [font=Courier]*.rbxmx[/font] is more readable.)

Do note, pre-built versions of Maui are always minified with [url=https://darklua.com]Darklua[/url], a Lua formatter. It is [b]not[/b] obfuscation, just minification.

If you don't know where your specific local-plugins folder is, in Studio, goto the "Plugins" tab via the ribbon-bar, and on the left there should be a "Plugins Folder" button, opening that will prompt the local plugins folder, where you will place the plugin in.

[img]https://media.discordapp.net/attachments/1060751075415687178/1060993996060631050/image.png[/img]
[/spoiler]

[spoiler="Building from Source"]
For building directly from source, you can view the latest build instructions in the [url=https://github.com/latte-soft/maui#installation]repository's README.md[/url].
[/spoiler]



[size=large][b]Usage[/b][/size]
In a new/existing Studio place, go to the [i]"Plugins"[/i] tab from the ribbon-menu, and you'll see a button similar to this:

[img]https://media.discordapp.net/attachments/1060751075415687178/1060815232076873728/image.png[/img]

Upon toggle, you should automatically see the widget, which from there has more instructions in the console! It is [i]always[/i] completely synced with [b]your[/b] Studio's color palette theme, with Fusion components similar to Studio's look & feel.

[img=420x259]https://media.discordapp.net/attachments/1060751075415687178/1060817600243830845/image.png[/img]

From there, just select an object, and click "Build"! Due to LuaEncode's EXTREMELY fast speeds and optimization, Maui usually only takes a few [i]milliseconds[/i] to create the output.

After the script is built, Maui should open the output script's editor window, and Maui will store information logs in the internal console.

[img=600x256]https://media.discordapp.net/attachments/1060751075415687178/1060818298213777418/image.png?width=1069&height=456[/img]

[img=450x258]https://media.discordapp.net/attachments/1060751075415687178/1060819391882731520/image.png[/img]

From there, you're done! You can run it in a script utility, another script, place it into obfuscation, etc.. It's 100% portable, and will work in almost [i]any[/i] Roblox environment!

[size=small][i]This is a simple test-script for using Fusion with an exploit, you can see the source [url=https://github.com/latte-soft/maui/blob/main/tests/HelloFusion]here[/url]![/i][/size]
[img=775x372]https://media.discordapp.net/attachments/1060751075415687178/1060976562654154772/image.png?width=950&height=456[/img]

[hr]

[size=x-large][b]The [font=Courier].maui[/font] Project Format[/b][/size]
[size=small][i]This is really meant for more advanced projects/modules you're packing, and right now there really isn't much outside of minification options.[/i][/size]

You can place a module named ".maui" under the model you're building, and Maui will expect the return to be a table of options. Here's a Lua template for this:

[code]return {
    FormatVersion = 1, -- Isn't necessary in the project file, but just for future proofing the format incase we ever change anything
    -- All output options
    Output = {
        MinifyTable = true, -- If the codegen table itself (made from LuaEncode) is to be minified
        UseMinifiedLoader" = true -- Use the pre-minified LoadModule script in the codegen, which is always predefined and not useful for debugging
    }
}[/code]

You can [i]also[/i] use [url=https://rojo.space/docs/v7/sync-details/#json-modules]Rojo's JSON module feature[/url] (if you're using Rojo) to store this module in JSON, which would obviously be a file named ".maui.json":

[code]{
    "FormatVersion": 1,
    "Output": {
        "MinifyTable": true,
        "UseMinifiedLoader": true
    }
}[/code]

Still keep in mind, you need to include this file in your [font=Courier]*.project.json[/font] file, if you're using Rojo.

[hr]

[size=x-large][b]Contributing[/b][/size]
[i]For now[/i], there really isn't any specific contribution instructions to follow. We're still working on our public Luau style-guide, so if you have an idea/implementation of something, show us your idea through an [url=https://github.com/latte-soft/maui/issues]issue[/url] or [url=https://github.com/latte-soft/maui/pulls]pull-request[/url]!

[hr]

[size=x-large][b]Conclusion[/b][/size]
If you still have further questions or want to look at the project for more information, visit the [url=https://github.com/latte-soft/maui]GitHub repository![/url]

[b]Also, make sure to join [url=https://latte.to/invite]our official Discord server[/url] for all discussion and updates on Maui, and future releases.[/b]

[hr]

[align=center][color=#ff6b6b][size=xx-large]<3[/size][/color][/align]

[align=center][size=x-small]and yes, I [url=https://github.com/latte-soft/maui/blob/main/THREAD.bb]manually wrote this thread in pure bbcode[/url], pls save me[/font][/color][/size]
[spoiler="maui ballin"][img]https://media.discordapp.net/attachments/1060751075415687178/1060773297370955788/maui-ballin.gif[/img][/spoiler][/align]
