#!/usr/bin/perl
use feature ':all';
use CGI::PSGI;
use HTTP::Server::Simple::PSGI; 
use FindBin;
use lib "$FindBin::Bin/lib/";
use LogHut::Config;
use LogHut::Controller::Panel;
my $app = sub {
     $env = shift;
     $q = CGI::PSGI->new($env);
     return [
         LogHut::Controller::Panel->new()->run()
     ];
};
my $server = HTTP::Server::Simple::PSGI->new('8080');
$server->app($app);
$server->host('127.0.0.1');
$server->run();
