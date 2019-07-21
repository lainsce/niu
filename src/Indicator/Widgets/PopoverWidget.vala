public class Niu.Widgets.PopoverWidget : Gtk.Grid {
    /* Button to hide the indicator */
    private Gtk.ModelButton show_niu_button;
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
        quit_niu_button = new Gtk.ModelButton ();
        quit_niu_button.text = _("Quit Niu");
        show_niu_button.clicked.connect (() => show_niu ());
        quit_niu_button.clicked.connect (() => quit_niu ());

        add (cal);
        add (show_niu_button);
        add (new Gtk.Separator (Gtk.Orientation.HORIZONTAL));
        add (quit_niu_button);

        show_all ();
    }
}

