# SentryNodeInstall
This script is based on John Kelly's work that can be found here:
  
      https://nodebasewm.github.io/docs/tutorials/sentrynodemanual/
It is highly recommened that user of this script should go through above guide to understand the innerworking of the installation script.

For this script to work, a X11 server is necessary to be running on client machine.

**Windows Client (Tested)**

1. Download X11 client that can be found here:

        https://mobaxterm.mobatek.net/download-home-edition.html
   
2. Once downloaded, open up a SSH session to the server where WM Sentry node will be installed.

        ssh <UserName>@xxx.xxx.xxx.xxx
   
4. Once logged in, execute the following command

        wget https://github.com/ConnectedEarth/SentryNodeInstall/archive/refs/heads/main.zip
        unzip main.zip 
        cd SentryNodeInstall-main/
         
6. Give execution permision to the file and then execute the file

       chmod +x install_WM_sentry_v1.sh
       ./install_WM_sentry_v1.sh
   
7. Once the installation is complete, check whether node is running fine or not.
   This can be done in two ways:
   a.using the following command

       sudo systemctl status cosmovisor.service
   
   b. By installing Ayaviw
   
        cd ~/
        mkdir nodebase-tools 
        cd nodebase-tools
        wget -O ayaview.zip https://github.com/nodebasewm/download/blob/main/ayaview.zip?raw=true
        unzip ayaview.zip
        rm ayaview.zip
       ./ayaview
     
**Linux and Mac Client (Un-tested)**

Linux and clients should have X11 server included. Please make sure they are enable.
Mac clients, please install a X11 sever and enable the display to accept remote connection. After that script should work.

       
 



  
