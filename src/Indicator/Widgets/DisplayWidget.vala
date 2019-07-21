public class Niu.Widgets.DisplayWidget : Gtk.Grid {
    public TimeWidget time;
    construct {
        valign = Gtk.Align.CENTER;

        time = new TimeWidget ();

        add (time);
    }
}

