// Generated by CoffeeScript 1.10.0
(function() {
  var BrowserWindow, app, path, shell;

  app = require('electron').app;

  BrowserWindow = require('electron').BrowserWindow;

  path = require('path');

  shell = require('electron').shell;

  app.on('ready', function() {
    var main_window, preload;
    preload = path.resolve(path.join(__dirname, 'preload.js'));
    console.log(preload);
    main_window = new BrowserWindow({
      width: parseInt(process.argv[3]) || 800,
      height: parseInt(process.argv[4]) || 600,
      webPreferences: {
        nodeIntegration: false,
        webSecurity: false,
        preload: preload
      },
      icon: path.resolve(path.join(__dirname, "icon.png")),
      preload: preload
    });
    main_window.loadURL(process.argv[2]);
    main_window.setMenu(null);
    main_window.toggleDevTools();
    return main_window.webContents.on('new-window', function(event, url) {
      event.preventDefault();
      return shell.openExternal(url);
    });
  });

}).call(this);