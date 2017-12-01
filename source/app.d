import gio.Application : GioApplication = Application;
import glib.Timeout;
import gtk.Application;
import gtk.ApplicationWindow;
import gtk.Box;
import gtk.Image;
import gtk.Label;
import gtk.Menu;
import gtk.MenuBar;
import gtk.MenuItem;

import resusageviewer.sysinfo;

void updateWindow(DisplaySysinfo info)
{
    info.updateCPUDisplay();
    info.updateRAMDisplay();
}

MenuItem createImageMenuItem(string label, string icon)
{
    auto item = new MenuItem;
    auto box = new Box(Orientation.HORIZONTAL, 6);
    auto image = new Image(icon);

    box.add(image);
    box.add(new Label(label));
    item.add(box);
    return item;
}

class DisplayResusage : ApplicationWindow
{
    this(Application application)
    {
        super(application);
        setTitle("Resource usage viewer");
        setPosition(GtkWindowPosition.CENTER);
        setDefaultSize(500, 700);
    }
}

void main(string[] args)
{
    auto application = new Application("org.gtkd.resourceviewer", GApplicationFlags.FLAGS_NONE);
    application.addOnActivate(delegate void(GioApplication app) {
        auto window = new DisplayResusage(application);

        auto displayTab = new DisplaySysinfo(window);
        auto verticalBox = new Box(GtkOrientation.VERTICAL, 0);
        auto menuBar = new MenuBar;
        auto menu = new Menu;
        auto file = new MenuItem("_File");
        auto quit = createImageMenuItem("Quit", "application-exit");

        menu.append(quit);
        file.setSubmenu(menu);
        menuBar.append(file);

        verticalBox.packStart(menuBar, false, false, 0);
        verticalBox.packStart(displayTab.scroll, true, true, 0);

        window.add(verticalBox);
        window.showAll();

        // g_timeout_add_seconds相当。 1秒間隔でウィンドウを更新。
        new Timeout(() { updateWindow(displayTab); return true; }, 1);

        // quitボタンが押されたら終了。
        quit.addOnActivate((MenuItem _) { app.quit(); });
    });
    application.run(args);
}
