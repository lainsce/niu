public class Niu.Widgets.TimeWidget : Gtk.Box {
    private Gtk.Label time_label;
    public string time_str {
        set { time_label.set_label ("%s".printf (value)); }
    }

    construct {
        var icon = new Gtk.Image ();
        icon.gicon = new ThemedIcon ("pager-checked-symbolic");
        icon.icon_size = 3;
        time_label = new Gtk.Label ("N/A");
        time_label.margin = 1;

        pack_start (icon);
        pack_start (time_label);
    }

    public TimeWidget () {
        orientation = Gtk.Orientation.HORIZONTAL;
    }
}

