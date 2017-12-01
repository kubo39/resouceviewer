module resusageviewer.sysinfo;

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
import std.conv : to;
import std.format;

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

ProgressBar createProgressBar(Grid layout, uint line, string label, string text)
{
    auto p = new ProgressBar;
    auto l = new Label(label);
    p.setText(text);
    p.setShowText(true);
    layout.attach(l, 0, line, 1, 1);
    layout.attach(p, 1, line, 11, 1);
    return p;
}

class DisplaySysinfo
{
    SystemCPUWatcher cpuWatcher;
    SystemMemInfo sysMemInfo;
    ProgressBar cpu;
    ProgressBar ram;
    ScrolledWindow scroll;

    this(Window win)
    {
        cpuWatcher = new SystemCPUWatcher;
        sysMemInfo = systemMemInfo();

        auto verticalLayout = new Box(Orientation.VERTICAL, 0);
        scroll = new ScrolledWindow;

        verticalLayout.setSpacing(5);

        verticalLayout.packStart(new Label("Current CPU usage"), false, false, 7);

        cpu = new ProgressBar;
        cpu.setMarginRight(5);
        cpu.setMarginLeft(5);
        cpu.setShowText(true);
        verticalLayout.add(cpu);

        auto layout1 = new Grid;
        layout1.setColumnHomogeneous(true);
        layout1.setMarginRight(5);

        createHeader("Memory Usage", verticalLayout);
        ram = createProgressBar(layout1, 0, "RAM", "");
        verticalLayout.packStart(layout1, false, false, 15);

        updateCPUDisplay();
        updateRAMDisplay();

        scroll.add(verticalLayout);
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

        auto totalRAM = sysMemInfo.totalRAM / 1024.0;
        auto usedRAM = sysMemInfo.usedRAM / 1024.0;

        string text;
        if (totalRAM < 100_000)
        {
            text = format("%g / %d kB", usedRAM, totalRAM.to!long);
        }
        else if (totalRAM < 10_000_000)
        {
            text = format("%g / %d MB", usedRAM / 1024.0, (totalRAM / 1024).to!long);
        }
        else if (totalRAM < 10_000_000_000)
        {
            text = format("%g / %d GB", usedRAM / 1_048_576.0, (totalRAM / 1_048_576).to!long);
        }
        else
        {
            text = format("%g / %d TB", usedRAM / 1_073_741_824.0, (totalRAM / 1_073_741_824).to!long);
        }
        ram.setText(text);
        if (totalRAM != 0)
        {
            ram.setFraction(sysMemInfo.usedRAMPercent / 100.0);
        }
        else
        {
            ram.setFraction(0.0);
        }
    }
}
