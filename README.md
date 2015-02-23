#tsprlng's dotfiles

Everyone else is doing it wrong, obviously.

You know how it's nice for vim and zsh to work consistently on various machines? Yeah.


### However

At work we use various servers (or AWS instances) that are always being destroyed and created; I can't start shoving my own config into the company Puppet repo and can't really depend on installing loads of crap to manage configuration either.

I also don't really want to waste several seconds and/or kilobytes on every machine keeping an oh-my-zsh repo and all that sort of crap.

### The plan

Use Ruby/Rake to generate files based on various different “environments” so that I can, from my desktop, push correct configurations to various other machines.

1. Compile files out to `/dist/#{environment-name}`
2. Push them somehow to the target machine, either:
    - Copy them to `/dist/exports` for local machine (checking it first for external changes somehow)
    - SCP/RSync them to some folder on remote machines
3. Link all the normal paths like `~/.zshrc` to these generated files.