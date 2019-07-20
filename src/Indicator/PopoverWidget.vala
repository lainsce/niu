public class Niu.Widgets.PopoverWidget : Gtk.Grid {
    /* Button to hide the indicator */
    private Gtk.ModelButton show_niu_button;
    private Gtk.ModelButton quit_niu_button;

    public signal void quit_niu ();
    public signal void show_niu ();

    construct {
        orientation = Gtk.Orientation.VERTICAL;

        show_niu_button = new Gtk.ModelButton ();
        quit_niu_button = new Gtk.ModelButton ();
        show_niu_button.clicked.connect (() => show_niu ());
        quit_niu_button.clicked.connect (() => quit_niu ());

        add (show_niu_button);
        add (new Wingpanel.Widgets.Separator ());
        add (quit_niu_button);
    }
}

