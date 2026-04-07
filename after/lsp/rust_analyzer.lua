return {
  settings = {
    ['rust-analyzer'] = {
      imports = {
        granularity = {
          enforce = true,
          group = 'crate',
        },
      },
      cargo = {
        buildScripts = {
          enable = true,
        },
      },
      procMacro = {
        enable = true,
      },
    },
  },
}
