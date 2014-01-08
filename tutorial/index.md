---
layout: default
title: Tutorial - using ASPAX with an Express.js application
description: A brief step-by-step guide on how to use ASPAX with Express.js
---
## Tutorial - using ASPAX with Express.js
Here are the quick steps on how to use ASPAX with an Express.js application:

1\. Create a folder structure similar to this one for your project:

{% highlight text %}

/client         -> asset sources
/server         -> main Express.js application folder
/server/public  -> public static folder

{% endhighlight %}

Notice: put all your asset sources in `/client`; **don't put anything** in `/server/public`, as **it will be overwritten**!

2\. Create `/client/aspax.yml` describing your assets configuration:

{% highlight yaml %}

js/app.js|fp|min:
  - lib/bootstrap/js/bootstrap.js
  - lib/moment.js
  - lib/jade/runtime.js
  - scripts/namespaces.coffee|bare
  - templates/now.jade
  - scripts/index.ls|bare

css/app.css|fp|min:
  - lib/bootstrap/css/bootstrap.css
  - lib/bootstrap/css/bootstrap-theme.css
  - styles/index.styl|nib

favicon.png: images/favicon.png

...

{% endhighlight %}

3\. Install ASPAX globally if you haven't already, install [aspax-express](https://github.com/icflorescu/aspax-express) in your application, and also make sure to install any necessary source handling plugins:

{% highlight sh %}

# Global ASPAX
npm install aspax -g

cd server

# ASPAX-Express
npm install aspax-express --save

# Source handling plugins
npm install aspax-coffee-handler --save-dev
npm install aspax-ls-handler --save-dev
npm install aspax-jade-handler --save-dev
npm install aspax-styl-handler --save-dev

{% endhighlight %}

4\. Add `require('aspax-express')(app, path.join(__dirname, 'aspax.json'))` **before handling views** in your main application script (usually `/server/app.js`):

{% highlight js %}

var express = require('express')
  , app = express();

...
require('aspax-express')(app, path.join(__dirname, 'aspax.json'));

app.use app.router;
app.get('/:page', function(req, res) {
...
});

{% endhighlight %}

5\. Wrap the URLs in your views into `asset()` function calls:

{% highlight jade %}

//- link(rel="shortcut icon", href="/favicon.png")
link(rel="shortcut icon", href=asset('/favicon.png'))

{% endhighlight %}

6\. In `/server` folder you can run any of these:

{% highlight sh %}

# watch and build on-the-fly during development
aspax -s ../client watch

# build for development
aspax -s ../client build

# pack for production (will compile, concat, minify and fingerprint)
aspax -s ../client pack

# clean everything
aspax -s ../client clean

{% endhighlight %}

7\. Run your application in either **development** or **production** mode:

{% highlight sh %}

# development
#
NODE_ENV=development node start.js
# ...or
NODE_ENV=development nodemon -e js,json,coffee -x node

# production
#
NODE_ENV=production node start.js

{% endhighlight %}

Notice: if you're using `nodemon` in development mode, add `aspax.json` to `.nodemonignore` to avoid restarting the application whenever an asset is rebuilt.

Have a look at [this demo repository](https://github.com/icflorescu/aspax-demo) to see it in action.
