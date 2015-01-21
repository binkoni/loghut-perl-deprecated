#!/usr/bin/perl
use feature ':all';
use HTTP::Server::Simple::PSGI;
use FindBin;
use lib "$FindBin::Bin/lib/";
use LogHut::Config;
use LogHut::Controller::Panel;
use LogHut::Request;
my $app = sub {
     my $env = shift;
     $q = LogHut::Request->new(env => $env);
     return [
         LogHut::Controller::Panel->new()->run()
     ];
};
my $server = HTTP::Server::Simple::PSGI->new('8080');
$server->app($app);
$server->host('127.0.0.1');
$server->run();
