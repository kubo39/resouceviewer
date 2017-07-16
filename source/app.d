import gio.Application : GioApplication = Application;
import glib.Timeout;
import gtk.Application;
import gtk.ApplicationWindow;
import gtk.Box;
import gtk.Image;
import gtk.Label;

import resusageviewer.notebook;
import resusageviewer.sysinfo;


void updateWindow(DisplaySysinfo info)
{
    info.updateCPUDisplay();
    info.updateRAMDisplay();
}

class DisplayResusage : ApplicationWindow
{
    this(Application application) {
        super(application);
        setTitle("Resource usage viewer");
        setPosition(GtkWindowPosition.CENTER);
        setDefaultSize(500, 700);
    }
}


void main(string[] args)
{
    auto application = new Application("org.gtkd.resourceeviewer",
                                       GApplicationFlags.FLAGS_NONE);
    application.addOnActivate(delegate void(GioApplication app) {
            auto window = new DisplayResusage(application);
            auto note = new NoteBook;

            auto displayTab  = new DisplaySysinfo(note, window);

            auto verticalBox = new Box(GtkOrientation.VERTICAL, 0);
            verticalBox.packStart(note.notebook, true, true, 0);

            window.add(verticalBox);
            window.showAll();

            new Timeout(1000, () {
                    updateWindow(displayTab);
                    return true;
            });
        });
    application.run(args);
}
