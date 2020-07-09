public class Niu.Widgets.TimeWidget : Gtk.Grid {
    private Gtk.Label time_label;
    public string time_str {
        set { time_label.set_label ("%s".printf (value)); }
    }

    construct {
        Gtk.IconTheme.get_default().add_resource_path("/com/github/lainsce/niu/icons");
        var settings = new GLib.Settings ("com.github.lainsce.niu");

        var icon = new Gtk.Image ();
        if (settings.get_boolean ("pomodoro")) {
            icon.set_from_icon_name ("pomodoro-symbolic", (Gtk.IconSize)3);
        } else {
            icon.set_from_icon_name ("no-pomodoro-symbolic", (Gtk.IconSize)3);
        }
        settings.changed.connect (() => {
            if (settings.get_boolean ("pomodoro")) {
                icon.set_from_icon_name ("pomodoro-symbolic", (Gtk.IconSize)3);
            } else {
                icon.set_from_icon_name ("no-pomodoro-symbolic", (Gtk.IconSize)3);
            }
        });
        time_label = new Gtk.Label ("XXX:XXX");

        attach (icon, 0, 0, 1, 1);
        attach (time_label, 1, 0, 1, 1);
    }

    public TimeWidget () {
        orientation = Gtk.Orientation.HORIZONTAL;
    }
}
