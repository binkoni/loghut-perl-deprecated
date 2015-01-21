LogHut
==
<img src="http://gonapps.io/blog/admin/res/loghut.svg" style="width:5rem;height:5rem"/><br/>
**LogHut** is a **static and lightweight blog management system** written in **Perl**.<br/>
This is very fast, so you can operate your blog even in Cubietruck or Raspberry Pi with no problems<br>
You can customize your blog with templates which use Template CPAN module for processing.<br/>
This project is still in development, you can also give some advice to the author to improve this application if you want.<br/>


How it works
--
First, let me clarify the meaning of 'static'.<br/>
The word 'static' means that all posts you write will be saved as html files, not in the database.<br/>
Because of this, you can run your blog even in low-performance machines<br/>
But 'static' doesn't mean that you should write posts, manage posts manually<br/>
You can do the jobs very conveniently such as creating posts, modifying posts, deleting posts, managing tags, downloading the backup<br/>

How to use
--
1. Suppose that your blog directory is '/blog'.
2. Install Perl module dependencies.
3. Download this repository at '/blog'.
4. The directory 'loghut' will be the admin page. You can rename this directory 'admin'.
5. Configure your webserver to pass proxy to 8080 port. All requests to '/blog/admin/index.pl' should be proxied.
6. Configure LogHut with 'Config.pm'.
7. Edit templates in '/blog/admin/res'. All templates must conform TemplateToolkit syntax.
8. Check read/write permissions and run '/blog/admin/index.pl'. this is the entry script.


Author
---
Byeonggon Lee (gonny952@gmail.com)


License
---
>Copyright (c) 2015, Byeonggon Lee <gonny952@gmail.com>
><br/>
>This program is free software: you can redistribute it and/or modify
>it under the terms of the GNU General Public License as published by
>the Free Software Foundation, either version 3 of the License, or
>(at your option) any later version.
><br/>
>This program is distributed in the hope that it will be useful,
>but WITHOUT ANY WARRANTY; without even the implied warranty of
>MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
>GNU General Public License for more details.
><br/>
>You should have received a copy of the GNU General Public License
>along with this program.  If not, see <http://www.gnu.org/licenses/>.


Perl module dependencies
---
* HTTP::Server::Simple::PSGI
* Template

Software dependencies
---
* Web server (nginx, apache, etc.)
* gzip
* tar

Supported operating systems
---
* Linux
* Maybe other Unices (Not tested)
