#!/usr/bin/perl
use HTTP::Server::Simple::PSGI; 
my $app = sub {
     use latest;
     use CGI::PSGI;
     use FindBin;
     use lib "$FindBin::Bin/lib/";
     use LogHut::Config;
     $env = shift;
     $q = CGI::PSGI->new($env);
     use LogHut::Controller::Panel;
     return [
         LogHut::Controller::Panel->new()->run()
     ];
};
my $server = HTTP::Server::Simple::PSGI->new('8080');
$server->app($app);
$server->host('127.0.0.1');
$server->run();
