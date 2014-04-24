PowerShell Windows Update Management
====================================
PowerShell Script for Windows Update Management

This script was created to manage updates in our entire 
environment, also on servers running in a DMZ.

Installation
------------
Create a site on an IIS 7.0(or higher) server and place all
the files in the root. Enable HTTPS for this site and disable
HTTP.

Run the following command on a server to install:
Invoke-WebRequest "https://<webserver>/bootstrap.ps1"