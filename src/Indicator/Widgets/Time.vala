public class Niu.Widgets.TimeWidget : Gtk.Box {
    private Gtk.Label time_label;
    public string time_str {
        set { time_label.set_label ("%s".printf (value)); }
    }

    construct {
        Gtk.IconTheme.get_default().add_resource_path("/com/github/lainsce/niu/icons");

        var icon = new Gtk.Image ();
        if (Niu.Application.gsettings.get_boolean ("pomodoro")) {
            icon.set_from_icon_name ("pomodoro-symbolic", (Gtk.IconSize)3);
        } else {
            icon.set_from_icon_name ("no-pomodoro-symbolic", (Gtk.IconSize)3);
        }
        Niu.Application.gsettings.changed.connect (() => {
            if (Niu.Application.gsettings.get_boolean ("pomodoro")) {
                icon.set_from_icon_name ("pomodoro-symbolic", (Gtk.IconSize)3);
            } else {
                icon.set_from_icon_name ("no-pomodoro-symbolic", (Gtk.IconSize)3);
            }
        });
        time_label = new Gtk.Label ("N/A");
        time_label.margin = 1;

        pack_start (icon);
        pack_start (time_label);
    }

    public TimeWidget () {
        orientation = Gtk.Orientation.HORIZONTAL;
    }
}
