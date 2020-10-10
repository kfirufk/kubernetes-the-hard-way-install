# kubernetes-the-hard-way-install
Trying to build a configuration generator script based on the kubernetes-the-hard-way project

in general i'm trying to understand how to configure kubernetes the hard way :)
so i'm creating a script to generate all the required files based on https://github.com/kelseyhightower/kubernetes-the-hard-way project.

so in general to use it, env.sh should be modified according to your needs to configure the 
workers and controllers.

In general I've got 3 Gentoo servers at home, I'm trying to make a script that will make my life easier installing it. so after the initial configuration i need to plan my  future todos.

TODO:
* there are some more static data like ips and such and that i need to move to env.sh
