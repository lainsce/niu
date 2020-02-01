public class Niu.Widgets.TimeWidget : Gtk.Grid {
    private Gtk.Label time_label;
    public string time_str {
        set { time_label.set_label ("%s".printf (value)); }
    }

    construct {
        Gtk.IconTheme.get_default().add_resource_path("/com/github/lainsce/niu/icons");

        var icon = new Gtk.Image ();
        var settings = AppSettings.get_default ();
        if (settings.pomodoro) {
            icon.set_from_icon_name ("pomodoro-symbolic", (Gtk.IconSize)3);
        } else {
            icon.set_from_icon_name ("no-pomodoro-symbolic", (Gtk.IconSize)3);
        }
        settings.changed.connect (() => {
            if (settings.pomodoro) {
                icon.set_from_icon_name ("pomodoro-symbolic", (Gtk.IconSize)3);
            } else {
                icon.set_from_icon_name ("no-pomodoro-symbolic", (Gtk.IconSize)3);
            }
        });
        time_label = new Gtk.Label ("N/A");
        time_label.margin = 1;

        attach (icon, 0, 0, 1, 1);
        attach (time_label, 1, 0, 1, 1);
    }

    public TimeWidget () {
        orientation = Gtk.Orientation.HORIZONTAL;
    }
}
