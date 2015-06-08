#!/usr/bin/env ruby

require 'fileutils'
require 'pp'

F = File
FU = FileUtils::Verbose

##
# The path to the directory(/repo) (normally ~/.dotfiles-local) where this script has been generated
#
DF_LOCAL_DIR = File.dirname(File.expand_path(__FILE__))

##
# Ensures that the file at proper_path is under the control of this system.
# i.e. ensures that proper_path is a symlink to a file in this .dotfiles-local repo, named name_here
#
# If not, copies the existing content into this repo and replaces the original with a link.
#
def link_file(name_here, proper_path)
  # expand all paths
  proper_path = F.expand_path(proper_path)
  name_here = F.join(DF_LOCAL_DIR, name_here)
  current_target = F.expand_path(F.readlink(proper_path), F.dirname(proper_path)) rescue nil
    # i.e. nil if file is not a symlink
  
  return false if name_here == current_target  # i.e. already linked correctly

  if current_target
    FU.ln_s(current_target, name_here, force: true)
      # if the file is already a symlink elsewhere, import it as a new one with absolute path
  else
    FU.rm_rf(name_here)
      # just replace any current content as it should be under Git's control anyway
      # TODO actually check that the content in-repo is safe (unmodified) before replacing it
    FU.copy_entry(proper_path, name_here)
  end

  FU.ln_s(name_here, proper_path, force: true)
  true
end

link_file('zshrc', '~/.zshrc')
