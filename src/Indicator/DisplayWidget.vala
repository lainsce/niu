public class Niu.Widgets.DisplayWidget : Gtk.Grid {

    private Gtk.Label a_label;

    public string time {
        set {
            a_label.set_label ("%s".printf (value));
        }
    }

    construct {
        valign = Gtk.Align.CENTER;

        a_label = new Gtk.Label ("");

        add (a_label);
    }
}

