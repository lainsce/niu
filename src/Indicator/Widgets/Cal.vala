public class Niu.Widgets.CalWidget : Gtk.Box {
    private Gtk.Label cal_label;
    public string cal_str {
        set { cal_label.set_label ("%s".printf (value)); }
    }
    construct {
        cal_label = new Gtk.Label ("N/A");
        cal_label.margin = 1;
        pack_start (cal_label);
    }
    public CalWidget () {
        orientation = Gtk.Orientation.HORIZONTAL;
    }
}

