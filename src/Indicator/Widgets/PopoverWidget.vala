public class Niu.Widgets.PopoverWidget : Gtk.Grid {
    private Gtk.ModelButton show_niu_button;
    public Wingpanel.Widgets.Switch start_pomodore_button;
    public Wingpanel.Widgets.Switch beats_button;
    private Gtk.ModelButton quit_niu_button;

    public signal void quit_niu ();
    public signal void show_niu ();

    public CalWidget cal;

    construct {
        orientation = Gtk.Orientation.VERTICAL;

        cal = new CalWidget ();

        show_niu_button = new Gtk.ModelButton ();
        show_niu_button.text = _("Show Niu…");
        show_niu_button.hexpand = true;
        show_niu_button.clicked.connect (() => show_niu ());

        start_pomodore_button = new Wingpanel.Widgets.Switch (_("Start Pomodoro…"), false);

        beats_button = new Wingpanel.Widgets.Switch (_("Show Only Beats"), false);
        beats_button.margin_bottom = 6;

        quit_niu_button = new Gtk.ModelButton ();
        quit_niu_button.text = _("Quit Niu");
        quit_niu_button.clicked.connect (() => quit_niu ());

        add (cal);
        add (show_niu_button);
        add (start_pomodore_button);
        add (beats_button);
        add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        add (quit_niu_button);

        show_all ();

        var settings = new GLib.Settings ("com.github.lainsce.niu");
        settings.bind ("pomodoro", start_pomodore_button, "active", GLib.SettingsBindFlags.DEFAULT);
        settings.bind ("beats", beats_button, "active", GLib.SettingsBindFlags.DEFAULT);
    }
}
