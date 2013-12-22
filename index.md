---
layout: default
title: ASPAX
description: The simplest Node.js asset packager
---
What if you could watch, compile, concatenate, minify, compress and fingerprint all your web assets using just a simple file written in clear, human-readable YML syntax?

Like this:

    js/app.js|fp|min|gz:
      - lib/bootstrap/js/bootstrap.js
      - lib/moment.js
      - lib/jade/runtime.js
      - scripts/namespaces.coffee|bare
      - templates/item.jade
      - scripts/index.ls|bare

    css/app.css|fp|min|gz:
      - lib/bootstrap/css/bootstrap.css
      - lib/bootstrap/css/bootstrap-theme.css
      - styles/index.styl|nib

    favicon.png:               images/favicon.png

    fonts/bs-glyphs.eot|fp:    lib/bootstrap/fonts/glyphicons-halflings-regular.eot
    fonts/bs-glyphs.svg|fp|gz: lib/bootstrap/fonts/glyphicons-halflings-regular.svg
    fonts/bs-glyphs.ttf|fp|gz: lib/bootstrap/fonts/glyphicons-halflings-regular.ttf
    fonts/bs-glyphs.woff|fp:   lib/bootstrap/fonts/glyphicons-halflings-regular.woff

That's it. No `initConfig()`, no complicated and redundant JavaScript or CoffeeScript code!...

***

By looking at a simple file named `aspax.yml` in the root of your assets folder, ASPAX CLI will:

- watch the folder and rebuild **just the necessary files** on changes;
- copy/rename or (compile + concatenate) files in **development mode**;
- copy/rename or (compile + concatenate + minify + compress + fingerprint) files for **production deployments**.

## Installing ASPAX
You'll most likely want ASPAX CLI installed as a global npm module:

    npm install aspax -g

## Installing plugins
To keep the global CLI module lightweight and dependency-free, ASPAX is using a plugin system to handle different source types such as CoffeeScript, LiveScript, client-side Jade templates, Stylus or LESS files, etc.

You'll have to install the necessary source-handling plugins in the folder in which you're running the CLI, like this:

    npm install aspax-contrib-coffee

See a list of [available plugins](#available-plugins) below.

## How to use
Type `aspax --help` to see all the available options and actions.

Here are just a few examples:

    # watch and build on-the-fly during development
    aspax -s ../assets watch

    # build for development
    aspax -s ../assets build

    # pack for production (will compile, concat, minify, compress and fingerprint)
    aspax -s ../assets pack

    # clean everything
    aspax -s ../client clean

## File syntax

### Fingerprinting, minifying and compressing
Just add the appropriate **flags** after the asset file name in `aspax.yml`:

                ┌─────────────┐
              ┌─┤ fingerprint │
              │ └─────────────┘
              │      ┌────────┐
              │  ┌───┤ minify │
              │  │   └────────┘
              │  │     ┌──────┐
              │  │   ┌─┤ gzip │
              │  │   │ └──────┘
              ┴─ ┴── ┴─
    js/app.js|fp|min|gz:
      - ...

The **flags** will have no effect in development mode, but in production:

- marking an asset for fingerprinting will add an UNIX timestamp like `-1387239833024` before its extension.
- marking an asset for minifying will process it with [UglifyJS2](https://github.com/mishoo/UglifyJS2)/[CSS-optimizer](https://github.com/css/csso) and will also add `.min` before the asset extensions;
- marking an asset for compression will gzip it and also add a `.gz` suffix to its name (all contemporary browsers are accepting gzipped files).

Notes:

- flags order is irrelevant;
- fingerprinting and compressing will work for anything, while minifying only makes sense for JS and CSS files;
- there's no point, of course, in trying to compress already compressed formats such as `.jpg`, `.png` or `.eot`.

### Source plugin flags
Some plugins are also accepting **flags** (i.e. `bare` for CoffeeScript files). Use the same syntax in `aspax.yml`:

       ┌─────────────────────┐
       │ compile without the │
       │ top-level function  ├──┐
       │ safety wrapper      │  │
       └─────────────────────┘  │
                                │
      - ...                   ──┴─
      - scripts/source.coffee|bare
      - ...

## Available plugins
When processing JS/CSS asset sources, ASPAx will look for plugins in `./node_modules`. Since you'll usually be running `aspax` in the web application folder, it's a good idea to install the necessary plugins like this `npm install aspax-contrib-coffee --save-dev`.

So far the avaiable plugins are:

- [aspax-contrib-coffee](http://github.com/icflorescu/aspax-contrib-coffee) for [CoffeeScript](http://coffeescript.org);
- [aspax-contrib-iced](http://github.com/icflorescu/aspax-contrib-iced) for [IcedCoffeeScript](http://maxtaco.github.io/coffee-script);
- [aspax-contrib-ls](http://github.com/icflorescu/aspax-contrib-ls) for [LiveScript](http://livescript.net);
- [aspax-contrib-jade](http://github.com/icflorescu/aspax-contrib-jade) for client-side [Jade](http://jade-lang.com) templates;
- [aspax-contrib-styl](http://github.com/icflorescu/aspax-contrib-styl) for [Stylus](http://learnboost.github.io/stylus);
- [aspax-contrib-less](http://github.com/icflorescu/aspax-contrib-less) for [LESS](http://lesscss.org).

If you need something else, please feel free to contribute with additional plugins (i.e. [SASS and SCSS](http://sass-lang.com)) and notify me so I can list them here.

## Developing additional plugins
Each plugin should be named 'aspax-contrib-xyz', where 'xyz' is the source extension (i.e. '.styl' for Stylus files) it refers to.

Each plugin module should export a `compile()` method with this signature (see example [here](https://github.com/icflorescu/aspax-contrib-coffee/blob/master/plugin.coffee#L5)):

    exports.compile = function(file, flags, callback) {
      ...
    };

...and a `findImports()` method to recursively find imported/referred files **where applicable** (i.e. by looking for `@import` statements in LESS files (like [this one](https://github.com/icflorescu/aspax-contrib-less)) or `include` statements in Jade (like [this one](https://github.com/icflorescu/aspax-contrib-jade)):

    exports.findImports = function(imports, file, callback) {
      ...
    };

Look at the available plugins above for detailed examples.

## FAQ

### Why is it called ASPAX?
**AS**set **PA**ckager + **X** because this utility is an evolution of [ASPA](http://github.com/icflorescu/aspa), a similar module I've built in the past.

### So why writing ASPAX instead of just updating [ASPA](http://github.com/icflorescu/aspa)?
ASPAX brings in some breaking changes by simplifying the YML file syntax and introducing a plugin system to handle various source files. Simply upgrading [ASPA](http://github.com/icflorescu/aspa) wouldn't be possible without annoying the happiness of too many users.

### I need ASPAX to handle .xyz source files
Let me know and maybe I can do it, or better yet, feel free to [contribute with a plugin](#developing-additional-plugins) and notify me, so I can list it in the [available plugins](#available-plugins) section above.

## Endorsing the author
If you find this piece of software useful, please [![endorse](https://api.coderwall.com/icflorescu/endorsecount.png)](https://coderwall.com/icflorescu) me on Coderwall!

## License
(The MIT License)

Copyright (c) 2013 Ionut-Cristian Florescu &lt;ionut.florescu@gmail.com&gt;

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
