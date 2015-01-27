#!/usr/bin/perl
use feature ':all';
use FindBin;
use lib "$FindBin::Bin/lib/";
use LogHut::Global;
use LogHut::Controller::Panel;
use LogHut::Request;
use LogHut::Server;

my $app = sub {
     my $env = shift;
     return [
         LogHut::Controller::Panel->new(request => LogHut::Request->new(env => $env))->run()
     ];
};

my $server = LogHut::Server->new(app => $app);
$server->run();

