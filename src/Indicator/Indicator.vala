public class Niu.Indicator : Wingpanel.Indicator {

    private Widgets.DisplayWidget? display_widget = null;
    private Widgets.PopoverWidget? popover_widget = null;
    private DBusClient dbusclient;

    construct {
        var settings = AppSettings.get_default ();
        this.visible = false;
        display_widget = new Widgets.DisplayWidget ();
        popover_widget = new Widgets.PopoverWidget ();

        dbusclient = DBusClient.get_default ();

        dbusclient.niu_vanished.connect (() => this.visible = false);
        dbusclient.niu_appeared.connect (() => this.visible = settings.indicator_state);

        dbusclient.interface.indicator_state.connect((state) => this.visible = state);
        dbusclient.interface.start_pomodore.connect((state) => {
            state = settings.pomodoro;
        });

        dbusclient.interface.update.connect((res) => {
            display_widget.time.time_str = res.ne;
            popover_widget.cal.cal_str = res.ar;
        });

        popover_widget.quit_niu.connect (() => {
            dbusclient.interface.quit_niu ();
            this.visible = false;
        });

        popover_widget.start_pomodore.connect (() => {
            dbusclient.interface.start_pomodore.connect((state) => state = settings.pomodoro);
        });

        popover_widget.show_niu.connect (() => {
            close ();
            dbusclient.interface.show_niu ();
        });
        popover_widget.show_all ();
    }

    /* Constructor */
    public Indicator () {
        /* Some information about the indicator */
        Object (code_name : "niu", /* Unique name */
                display_name : _("Niu Indicator"), /* Localised name */
                description: _("Show Niu indicator")); /* Short description */
    }

    /* This method is called to get the widget that is displayed in the top bar */
    public override Gtk.Widget get_display_widget () {
        return display_widget;
    }

    /* This method is called to get the widget that is displayed in the popover */
    public override Gtk.Widget? get_widget () {
        return popover_widget;
    }

    /* This method is called when the indicator popover opened */
    public override void opened () {
        /* Use this method to get some extra information while displaying the indicator */
    }

    /* This method is called when the indicator popover closed */
    public override void closed () {
    }
}

/*
 * This method is called once after your plugin has been loaded.
 * Create and return your indicator here if it should be displayed on the current server.
 */
public Wingpanel.Indicator? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    /* A small message for debugging reasons */
    debug ("Activating Niu Indicator");

    /* Check which server has loaded the plugin */
    if (server_type != Wingpanel.IndicatorManager.ServerType.SESSION) {
        /* We want to display our niu indicator only in the "normal" session, not on the login screen, so stop here! */
        return null;
    }

    /* Create the indicator */
    var indicator = new Niu.Indicator ();

    /* Return the newly created indicator */
    return indicator;
}
