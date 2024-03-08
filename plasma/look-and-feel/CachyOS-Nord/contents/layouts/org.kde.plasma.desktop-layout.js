var panel = new Panel
panel.location = "bottom"
panel.hiding = "normal"
panel.height = 2 * Math.floor(gridUnit * 1.8 / 2) // Adjusted for script consistency
panel.lengthMode = "manual"
panel.alignment = "center"
panel.maximumLength = 85.375 * gridUnit
panel.minimumLength = 85.375 * gridUnit
panel.offset = 0

// Adding Kickoff Launcher
var launcher = panel.addWidget("org.kde.plasma.kickoff")
launcher.currentConfigGroup = ["Shortcuts"];
launcher.writeConfig("global", "Alt+F1");

// Change the launcher icon
launcher.currentConfigGroup = ["/Configuration/General"];
launcher.writeConfig("icon", "cachyos");

// Adding Panel Spacer
panel.addWidget("org.kde.plasma.panelspacer")

// Adding Icon Tasks
panel.addWidget("org.kde.plasma.icontasks")

// Another Panel Spacer
panel.addWidget("org.kde.plasma.panelspacer")

// System Tray
panel.addWidget("org.kde.plasma.systemtray")

// Digital Clock without showing date
var clock = panel.addWidget("org.kde.plasma.digitalclock")
clock.currentConfigGroup = ["/"]
clock.writeConfig("showDate", false)

// Set desktop wallpaper for each desktop in the current activity
var desktopsArray = desktopsForActivity(currentActivity());
for(var j = 0; j < desktopsArray.length; j++) {
    desktopsArray[j].wallpaperPlugin = 'org.kde.image';
    desktopsArray[j].currentConfigGroup = ["/Wallpaper/org.kde.image/General"];
    desktopsArray[j].writeConfig("Image", "file:///home/lara/Imágenes/stretched-1366-768-320259.jpg");
}
