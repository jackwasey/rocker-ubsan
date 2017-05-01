#!/usr/bin/perl

# https://blog.afoolishmanifesto.com/posts/how-to-enable-ptrace-in-docker-1.10/

use strict;
use warnings;

# for more info check out https://docs.docker.com/engine/security/seccomp/

# This script simply helps to mutate the default docker seccomp profile.  Run it
# like this:
#
#     curl https://raw.githubusercontent.com/docker/docker/master/profiles/seccomp/default.json | \
#           build-seccomp > myapp.json

use JSON;

my $in = decode_json(do { local $/; <STDIN> });
push @{$in->{syscalls}}, +{
  name => 'ptrace',
  action => 'SCMP_ACT_ALLOW',
  args => []
} unless grep $_->{name} eq 'ptrace', @{$in->{syscalls}};

print encode_json($in);

