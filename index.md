---
layout: default
title: ASPAX
description: The simple Node.js asset packager. Watch, compile, concatenate, minify and fingerprint all your web assets based on a simple, human-readable file.
---
What if you could watch, compile, concatenate, minify and fingerprint all your web assets using just a simple file written in clear, human-readable YML syntax?

{% highlight yaml %}

js/app.js|fp|min:
  - lib/bootstrap/js/bootstrap.js
  - lib/moment.js
  - lib/jade/runtime.js
  - scripts/namespaces.coffee|bare
  - templates/item.jade
  - scripts/index.ls|bare

css/app.css|fp|min:
  - lib/bootstrap/css/bootstrap.css
  - lib/bootstrap/css/bootstrap-theme.css
  - styles/index.styl|nib

favicon.png:             images/favicon.png

fonts/bs-glyphs.eot|fp:  lib/bootstrap/fonts/glyphicons-halflings-regular.eot
fonts/bs-glyphs.svg|fp:  lib/bootstrap/fonts/glyphicons-halflings-regular.svg
fonts/bs-glyphs.ttf|fp:  lib/bootstrap/fonts/glyphicons-halflings-regular.ttf
fonts/bs-glyphs.woff|fp: lib/bootstrap/fonts/glyphicons-halflings-regular.woff

{% endhighlight %}

That's it. No complicated `.initConfig()`, no redundant code to describe tasks in JavaScript or CoffeeScript, just a simple YML file in your assets folder.

By looking at that file, ASPAX will:

- watch the folder and rebuild **just the necessary files** on changes;
- compile, concatenate and copy files in development mode;
- compile, concatenate, **minify**, **fingerprint** and copy files in production mode.

## Installation
Most likely you'll want ASPAX [![NPM version](https://badge.fury.io/js/aspax.png)](http://badge.fury.io/js/aspax) installed as a global module:

{% highlight sh %}

npm install aspax -g

{% endhighlight %}

## Plugins
To keep the global CLI module lightweight and dependency-free, ASPAX is using a plugin system to handle different source types such as CoffeeScript, LiveScript, client-side Jade templates, Stylus or LESS files, etc.

ASPAX will look for plugins in `./node_modules` folder, so you'll have to install the necessary source handlers like this:

{% highlight sh %}

npm install aspax-coffee-handler

{% endhighlight %}

If you're running ASPAX in a Node.js application root folder, consider using the `--save-dev` option to avoid deploying the plugins to your production environment:

{% highlight sh %}

npm install aspax-coffee-handler --save-dev

{% endhighlight %}

### Available plugins
So far, the available plugins are:

- [![NPM version](https://badge.fury.io/js/aspax-coffee-handler.png)](http://badge.fury.io/js/aspax-coffee-handler) [aspax-coffee-handler](http://github.com/icflorescu/aspax-coffee-handler) for [CoffeeScript](http://coffeescript.org);
- [![NPM version](https://badge.fury.io/js/aspax-iced-handler.png)](http://badge.fury.io/js/aspax-iced-handler) [aspax-iced-handler](http://github.com/icflorescu/aspax-iced-handler) for [IcedCoffeeScript](http://maxtaco.github.io/coffee-script);
- [![NPM version](https://badge.fury.io/js/aspax-ls-handler.png)](http://badge.fury.io/js/aspax-ls-handler) [aspax-ls-handler](http://github.com/icflorescu/aspax-ls-handler) for [LiveScript](http://livescript.net);
- [![NPM version](https://badge.fury.io/js/aspax-jade-handler.png)](http://badge.fury.io/js/aspax-jade-handler) [aspax-jade-handler](http://github.com/icflorescu/aspax-jade-handler) for client-side [Jade](http://jade-lang.com) templates;
- [![NPM version](https://badge.fury.io/js/aspax-styl-handler.png)](http://badge.fury.io/js/aspax-styl-handler) [aspax-styl-handler](http://github.com/icflorescu/aspax-styl-handler) for [Stylus](http://learnboost.github.io/stylus);
- [![NPM version](https://badge.fury.io/js/aspax-less-handler.png)](http://badge.fury.io/js/aspax-less-handler) [aspax-less-handler](http://github.com/icflorescu/aspax-less-handler) for [LESS](http://lesscss.org).

If you need something else, please let me know and maybe I can do it, or better yet, feel free to do it yourself and notify me so I can list it here.

### Developing additional plugins
Each plugin npm should be named `aspax-xyz-handler`, where `xyz` is the file extension it refers to.

Each plugin npm should export a `compile()` method with this signature (see example [here](https://github.com/icflorescu/aspax-coffee-handler/blob/master/plugin.coffee)):

{% highlight js %}

exports.compile = function(file, flags, callback) {
  ...
};

{% endhighlight %}

...and optionally a `findImports()` method to recursively find imported/referred files (see examples [here](https://github.com/icflorescu/aspax-less-handler/blob/master/plugin.iced) and [here](https://github.com/icflorescu/aspax-jade-handler/blob/master/plugin.iced)):

{% highlight js %}

exports.findImports = function(imports, file, callback) {
  ...
};

{% endhighlight %}

## Usage
The two main options are:
- `-s, --src <source>`: Assets source folder;
- `-d, --dst <destination>`: Assets destination folder - defaults to `public` in current folder.

You can type `aspax --help` in the console for advanced usage, but here are just a few CLI usage examples:

{% highlight sh %}

# watch and build on-the-fly during development
aspax -s ../assets watch

# build for development
aspax -s ../assets build

# pack for production (will compile, concat, minify and fingerprint)
aspax -s ../assets pack

# clean everything
aspax -s ../client clean

{% endhighlight %}

### Using assets built and packaged by ASPAX in an Express.js application
See [this tutorial](/tutorial) for a nice step-by-step guide on how to use ASPAX with Express.js.

## Config file syntax
The syntax of `aspax.yml` should be quite simple and human-friendly. Here are just a few tips:

### Marking assets for fingerprinting and minification
Just add the appropriate **flags** after the asset file name (the order is irrelevant):

{% highlight text %}

          o-- fingerprint
          |  o---- minify
          |  |
          |  |
          V  V
          -- ---
js/app.js|fp|min:
  - ...

{% endhighlight %}

The **flags** will have no effect in development mode, but in production:

- marking an asset for fingerprinting will add a UNIX timestamp like `-1387239833024` before its extension;
- marking an asset for minification will process it with [UglifyJS2](https://github.com/mishoo/UglifyJS2)/[CSS-optimizer](https://github.com/css/csso) and will also add `.min` before the extension.

Note: fingerprinting will work for anything, while minification only makes sense for JS and CSS files.

### Plugin flags
Some source-handling plugins are also accepting **flags** (i.e. `bare` for CoffeeScript files). Use the same syntax:

{% highlight text %}

   o---------------------o
   | compile without the |
   | top-level function  |--o
   | safety wrapper      |  |
   o---------------------o  |
                            V
  - ...                   ----
  - scripts/source.coffee|bare
  - ...

{% endhighlight %}

## FAQ

### What's the meaning of the name?
**AS**set **PA**ckager, and **X** because ASPAX is an evolution of [ASPA](http://github.com/icflorescu/aspa), a similar module I've built in the past.

### So why writing ASPAX instead of just updating ASPA?
ASPAX brings in some breaking changes by simplifying the YML file syntax and introducing a plugin system to handle various source files. Simply updating ASPA wouldn't have been possible without annoying the happiness of too many users.

### How long do you plan to maintain ASPAX?
I'm a strong advocate of open-source philosophy and I'm also using this module in my Node.js projects, so I'll do my best to keep it up to date. If you notice ASPAX has outdated depencencies, most likely there's going to be an update soon.

[![Dependency Status](https://david-dm.org/icflorescu/aspax.png)](https://david-dm.org/icflorescu/aspax)

### What projects / websites are using assets packaged by ASPAX?
To name just a few:

- [LeasingSH.ro](http://www.leasingsh.ro);
- [interiordelight.ro](http://www.interiordelight.ro);
- [aspax.github.io](http://aspax.github.io) (of course ;-).

If you think your project should be listed here, don't hesitate to [let me know](http://github.com/icflorescu) about it.

## Endorsing the author
If you find this piece of software useful, please [tweet about it](http://twitter.com/share?text=Checkout%20ASPAX%2C%20the%20simple%20Node.js%20asset%20packager!&url=http%3A%2F%2Faspax.github.io&hashtags=aspax&via=icflorescu) and/or [![endorse](https://api.coderwall.com/icflorescu/endorsecount.png)](https://coderwall.com/icflorescu) me on Coderwall!
