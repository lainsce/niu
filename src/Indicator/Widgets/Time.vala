public class Niu.Widgets.TimeWidget : Gtk.Box {
    private Gtk.Label time_label;
    private Gtk.Label time_indicator_text;
    string text;
    public string time_str {
        set { time_label.set_label ("%s".printf (value)); }
    }

    construct {
        var icon = new Gtk.Image.from_icon_name ("appointment-next-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        time_indicator_text = new Gtk.Label (text);

        time_label = new Gtk.Label ("N/A");
        time_label.margin = 1;

        pack_start (icon);
        pack_start (time_label);
    }

    public TimeWidget () {
        orientation = Gtk.Orientation.HORIZONTAL;
    }
}

