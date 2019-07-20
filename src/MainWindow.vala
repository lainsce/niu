/*
* Copyright (c) 2019 Lains
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/
namespace Niu {
    public class MainWindow : Gtk.ApplicationWindow {
        private Gtk.Label a_label;
        private Gtk.Label n_label;
        private Gtk.Switch show_indicator_switch;

        public string arvelie;
        public string neralie;

        public DBusServer dbusserver;
        public Updater updater;
        public GLib.DateTime date;

        public MainWindow (Gtk.Application application) {
            GLib.Object (application: application,
                         icon_name: "com.github.lainsce.niu",
                         resizable: false,
                         height_request: 320,
                         width_request: 500,
                         border_width: 6
            );

            updater = Updater.get_default (this);
            dbusserver = DBusServer.get_default();
            var settings = AppSettings.get_default ();

            updater.update.connect ((sysres) => {
                dbusserver.update (sysres);
                dbusserver.indicator_state (settings.indicator_state);
            });

            dbusserver.quit.connect (() => application.quit());
            dbusserver.show.connect (() => {
                this.deiconify();
                this.present();
                this.show_all ();
            });

            dbusserver.indicator_state (settings.indicator_state);
        }

        construct {
            get_style_context ().add_class ("rounded");
            get_style_context ().add_class ("niu-window");
            var settings = AppSettings.get_default ();
            date = new GLib.DateTime.now ();

            var provider = new Gtk.CssProvider ();
            provider.load_from_resource ("/com/github/lainsce/niu/stylesheet.css");
            Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

            var titlebar = new Gtk.HeaderBar ();
            titlebar.has_subtitle = false;
            titlebar.show_close_button = true;
            var titlebar_style_context = titlebar.get_style_context ();
            titlebar_style_context.add_class (Gtk.STYLE_CLASS_FLAT);
            titlebar_style_context.add_class ("niu-toolbar");
            set_titlebar (titlebar);

            //TRANSLATORS: Do not translate Horarie as it is a proper name!
            var label = new Gtk.Label (_("In the Horarie system, it is now…"));
            label.halign = Gtk.Align.START;
            label.hexpand = true;
            var label_style_context = label.get_style_context ();
            label_style_context.add_class (Granite.STYLE_CLASS_H3_LABEL);
            label_style_context.add_class ("niu-info");

            a_label = new Gtk.Label ("");
            a_label.hexpand = true;
            a_label.halign = Gtk.Align.END;
            var a_label_style_context = a_label.get_style_context ();
            a_label_style_context.add_class (Granite.STYLE_CLASS_H2_LABEL);
            a_label_style_context.add_class ("bold");

            n_label = new Gtk.Label ("");
            n_label.hexpand = true;
            n_label.halign = Gtk.Align.END;
            var n_label_style_context = n_label.get_style_context ();
            n_label_style_context.add_class (Granite.STYLE_CLASS_H2_LABEL);
            n_label_style_context.add_class ("niu-n");

            var help_button = new Gtk.Button ();
            help_button.set_image (new Gtk.Image.from_icon_name ("help-contents-symbolic", Gtk.IconSize.SMALL_TOOLBAR));
            help_button.set_always_show_image (true);
            help_button.vexpand = false;
            //TRANSLATORS: Do not translate Horarie as it is a proper name!
            help_button.tooltip_text = _("Learn about Horarie");
            var help_button_style_context = help_button.get_style_context ();
            help_button_style_context.add_class (Gtk.STYLE_CLASS_FLAT);
            help_button_style_context.add_class ("niu-button");
            help_button_style_context.remove_class ("image-button");

            help_button.clicked.connect (() => {
                try {
                    GLib.AppInfo.launch_default_for_uri("https://wiki.xxiivv.com/#time", null);
                } catch (GLib.Error e) {
                    warning ("Exception found: "+ e.message);
                }
            });

            var preferences_button = new Gtk.MenuButton ();
            preferences_button.has_tooltip = true;
            preferences_button.tooltip_text = (_("Settings"));
            preferences_button.set_image (new Gtk.Image.from_icon_name ("open-menu-symbolic", Gtk.IconSize.SMALL_TOOLBAR));
            titlebar.pack_end (preferences_button);

            var preferences_grid = new Gtk.Grid ();
            preferences_grid.margin = 6;
            preferences_grid.row_spacing = 6;
            preferences_grid.column_spacing = 12;
            preferences_grid.orientation = Gtk.Orientation.VERTICAL;

            var preferences_popover = new Gtk.Popover (null);
            preferences_popover.add (preferences_grid);
            preferences_button.popover = preferences_popover;

            var indicator_label = new Gtk.Label (_("Show an indicator:"));
            indicator_label.halign = Gtk.Align.END;

            show_indicator_switch = new Gtk.Switch ();
            show_indicator_switch.state = settings.indicator_state;

            show_indicator_switch.notify["active"].connect (() => {
                settings.indicator_state = show_indicator_switch.state;
                dbusserver.indicator_state (show_indicator_switch.state);
            });

            preferences_grid.attach (indicator_label, 0, 0, 1, 1);
            preferences_grid.attach (show_indicator_switch, 1, 0, 1, 1);

            preferences_grid.show_all ();

            var main_grid = new Gtk.Grid ();
            main_grid.orientation = Gtk.Orientation.VERTICAL;
            main_grid.margin = 6;
            main_grid.margin_top = main_grid.margin_bottom = 0;
            main_grid.row_homogeneous = true;
            main_grid.attach (label, 0, 0, 2, 1);
            main_grid.attach (n_label, 0, 1, 2, 1);
            main_grid.attach (help_button, 0, 2);
            main_grid.attach (a_label, 1, 2);

            add (main_grid);

            set_labels (date);

            Timeout.add_seconds (10, () => {
                set_labels (date);
                return false;
            });

            int x = settings.window_x;
            int y = settings.window_y;
            if (x != -1 && y != -1) {
                move (x, y);
            }
        }

        public void set_labels (GLib.DateTime date) {
            n_label.set_label (get_neralie_time_str (date));
            a_label.set_label (get_arvelie_calendar_str (date));
        }

        public string get_arvelie_calendar_str (GLib.DateTime date) {
            string resm = "";
            double resd;
            string m = "";
            string d = "";
            var doty = date.format ("%j").to_double ();
            var y = date.get_year ().to_string ().substring (2, 2);
            if (doty == 364 || doty == 365) {
                m = "+";
            } else {
                // Ascii: 97 = A
                double l = Math.floor(((doty) / 364) * 26);
                double an = 97 + l;
                resm = ((char)an).to_string ().up ();
                m = resm;
            }
            if (doty == 365) {
                d = "1";
            } else if (doty == 366) {
                d = "2";
            } else {
                resd = ((doty % 14) + 1);
                if (resd < 10) {
                    d = "0" + resd.to_string ();
                } else {
                    d = resd.to_string ();
                }
            }
            arvelie = "%s%s%s".printf (y, m, d);
            return arvelie;
        }

        public string get_neralie_time_str (GLib.DateTime date) {
            string ms = date.get_microsecond ().to_string ();
            string val = (ms.to_double () / 8640 / 10000).to_string ();
            neralie = "%s:%s".printf(val.substring(2, 3), val.substring(5, 3));
            return neralie;
        }

        public override bool delete_event (Gdk.EventAny event) {
            int x, y;
            get_position (out x, out y);
            var settings = AppSettings.get_default ();
            settings.window_x = x;
            settings.window_y = y;
            settings.indicator_state = show_indicator_switch.state;
            return false;
        }
    }
}
