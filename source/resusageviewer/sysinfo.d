module resusageviewer.sysinfo;

import std.conv : to;
import std.format;

import gtk.Box;
import gtk.CheckButton;
import gtk.Grid;
import gtk.Label;
import gtk.ProgressBar;
import gtk.ScrolledWindow;
import gtk.Widget;
import gtk.Window;
import resusage.cpu;
import resusage.memory;

import resusageviewer.notebook;


void createHeader(string labelText, Box parentLayout)
{
    auto label = new Label(labelText);
    auto empty = new Label("");
    auto grid = new Grid;
    auto horizontalLayout = new Box(Orientation.HORIZONTAL, 0);
    horizontalLayout.packStart(new Label(""), true, true, 0);
    grid.attach(empty, 0, 0, 3, 1);
    grid.attachNextTo(label, empty, PositionType.RIGHT, 3, 1);
    grid.attachNextTo(horizontalLayout, label, PositionType.RIGHT, 3, 1);
    grid.setColumnHomogeneous(true);
    parentLayout.packStart(grid, false, false, 15);
}

ProgressBar createProgressBar(Grid nonGraphLayout,
                              uint line, string label, string text)
{
    auto p  = new ProgressBar;
    auto l = new Label(label);
    p.setText(text);
    p.setShowText(true);
    nonGraphLayout.attach(l, 0, line, 1, 1);
    nonGraphLayout.attach(p, 1, line, 11, 1);
    return p;
}

class DisplaySysinfo
{
    SystemCPUWatcher cpuWatcher;
    SystemMemInfo sysMemInfo;
    ProgressBar cpu;
    ProgressBar ram;

    this(NoteBook note, Window win) {
        cpuWatcher = new SystemCPUWatcher;
        sysMemInfo = systemMemInfo();

        auto verticalLayout = new Box(Orientation.VERTICAL, 0);
        auto scroll = new ScrolledWindow;

        verticalLayout.setSpacing(5);

        auto nonGraphLayout = new Grid;
        nonGraphLayout.setColumnHomogeneous(true);
        nonGraphLayout.setMarginRight(5);

        verticalLayout.packStart(new Label("Current CPU usage"), false, false, 7);

        cpu = new ProgressBar;
        cpu.setMarginRight(5);
        cpu.setMarginLeft(5);
        cpu.setShowText(true);
        double percent = cpuWatcher.current();
        cpu.setText(format("%s%%", percent));
        cpu.setFraction(percent / 100);
        verticalLayout.add(cpu);

        createHeader("Memory Usage", verticalLayout);
        ram = createProgressBar(nonGraphLayout, 0, "RAM", "");
        verticalLayout.packStart(nonGraphLayout, false, false, 15);

        scroll.add(verticalLayout);
        note.createTab("System usage", scroll);

        updateRAMDisplay();
    }

    void updateCPUDisplay()
    {
        double percent = cpuWatcher.current();
        cpu.setText(format("%s%%", percent));
        cpu.setFraction(percent / 100.0);
    }

    void updateRAMDisplay()
    {
        sysMemInfo.update();
        auto totalRAM = sysMemInfo.totalRAM;
        auto usedRAM = sysMemInfo.usedRAM;

        string text;
        if (totalRAM < 100000) {
            text = format("%d / %d kB", usedRAM, totalRAM);
        } else if (totalRAM < 10000000) {
            text = format("%g / %d MB", usedRAM / 1024.0, totalRAM / 1024);
        } else if (totalRAM < 10000000000) {
            text = format("%g / %d GB", usedRAM / 1048576.0, totalRAM / 1048576);
        } else {
            text = format("%g / %d TB", usedRAM / 1073741824.0, totalRAM / 1073741824);
        }
        ram.setText(text);
        if (totalRAM != 0) {
            ram.setFraction(sysMemInfo.usedRAMPercent / 100.0);
        } else {
            ram.setFraction(0.0);
        }
    }
}

