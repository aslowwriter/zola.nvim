# Zola.nvim

Making using zola that bit easier. This is a plugin to help with zola workflows


## Features

- lua function to create and open new pages/sections so you can start writing immediately
- a `blink.cmp` source to provide autocomplet for the following things:
    - internal links (using zola's `@` link syntax)
    - shortcodes when inside a `{{ }}`

## Installation

This plugin requires `plenary` to function. I recommend pinning to the latest release tag, e.g. using
[lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    'aslowwriter/zola.nvim',
    dependencies = {
        'nvim-lua/plenary.nvim',
        -- optional but recommended
        'saghen/blink.cmp'
    }
}

```

## Configuration

`zola.nvim` accepts the following configuration:

```lua

M.config = {
    draft_by_default = false, -- if true newly created pages and sections are marked as drafts
    page_is_dir = false, -- if true pages are located at `slug/index.md` instead of `slug.md`
}

```

if you want to make use of the `blink.cmp` integraion you'll have to add it to that config as well:

```lua
return {
  'saghen/blink.cmp',
  opts = {
    sources = {
      default = { 'zola_content_path', 'zola_shortcodes' }, -- <-- add the appropriate ones here so they load
      providers = {
        zola_content_path = { module = 'zola.sources.content_paths'} -- <-- add this one for @ completion
        zola_shortcodes = { module = 'zola.sources.shortcodes'} -- <-- add this one for {{ }} completion
      },
    },
  },
}
```

If it is correctly configured it will be enabled any time you open a markdown file in a project with a `content` folder
and will trigger on `@`

## Usage

The main entrypoint of this plugin is the `create` lua function and you can call it like so:

```lua
require('zola').create {
    slug = 'blog/writing-an-nvim-plugin', -- where to place the new page/section
    kind = 'page', -- options are either `page` or `section`
    draft = true, -- whether to make the new page/section as draft, if not specified will default to the plugin config value
    page_is_dir = false, -- if true pages are located at `slug/index.md` instead of `slug.md`
    taxonomies = { -- these will be added to the new page/section
        tags = { 'lua', 'nvim' }, -- can specify multiple ones
        category = 'tutorial', -- or just one
    },
}

```

If provided they will override anything listed in the plugin config.

There is also a `create_interactive` version that will use `vim.ui.input` to prompt you for a slug and will pass any
of the other options onto the main `create` . It also accepts a `prefix` option in case you want to by default create
it in a certain place.

by default the plugin doesn't add any keybindings but using `create_interactive` you can easily create ones in a flexible way.
for example here is how I have them configured:

```lua
  keys = {
    {
      '<leader>zs',

      function()
        require('zola').create_interactive {
          kind = 'section',
          prefix = 'blog',
        }
      end,
      desc = 'Create a new blog section',
    },
    {
      '<leader>zz',
      function()
        require 'zola'
      end,
    },

    {
      '<leader>zp',
      function()
        require('zola').create_interactive {
          kind = 'page',
          prefix = 'blog',
        }
      end,

      desc = 'Create a new blog post',
    },
  },

```
