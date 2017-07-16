module resusageviewer.notebook;

import gtk.Box;
import gtk.Label;
import gtk.Notebook;
import gtk.Widget;

class NoteBook
{
    Notebook notebook;
    Box[] tabs;

    this() {
        notebook = new Notebook;
        tabs = [];
    }

    uint createTab(string title, Widget widget) {
        auto label = new Label(title);
        auto tab = new Box(Orientation.HORIZONTAL, 0);

        tab.packStart(label, true, true, 0);
        tab.showAll();

        auto index = notebook.appendPage(widget, tab);
        tabs ~= tab;
        return index;
    }
}
