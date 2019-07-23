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
        private Gtk.Switch background_switch;
        private Utils.Resources res;

        public DBusServer dbusserver;
        public Updater updater;

        public MainWindow (Gtk.Application application) {
            GLib.Object (application: application,
                         icon_name: "com.github.lainsce.niu",
                         resizable: false,
                         height_request: 320,
                         width_request: 500,
                         border_width: 6
            );

            this.set_application (application);

            updater = Updater.get_default ();
            dbusserver = DBusServer.get_default();
            var settings = AppSettings.get_default ();

            updater.update.connect ((res) => {
                dbusserver.update (res);
                dbusserver.indicator_state (settings.indicator_state);
                if (res.po) {
                    Timeout.add_seconds (777, () => {
                        pomodore_rest_notification ();
                        return false;
                    });
                    Timeout.add_seconds (1555, () => {
                        pomodore_drink_notification ();
                        return false;
                    });
                    Timeout.add_seconds (2332, () => {
                        pomodore_stand_notification ();
                        return false;
                    });
                }
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

            //TRANSLATORS: Do not translate Time as it is a proper name!
            var label = new Gtk.Label (_("In the Time system, it is now…"));
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
            //TRANSLATORS: Do not translate Time as it is a proper name!
            help_button.tooltip_text = _("Learn about Time");
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

            var background_label = new Gtk.Label (_("Start in background:"));
            background_label.halign = Gtk.Align.END;

            background_switch = new Gtk.Switch ();
            background_switch.state = settings.background_state;
            set_background_switch_state ();

            background_switch.notify["active"].connect (() => {
                settings.background_state = background_switch.state;

                if (!show_indicator_switch.active && background_switch.active) {
                    show_indicator_switch.active = true;
                }
            });

            show_indicator_switch.notify["active"].connect (() => {
                settings.indicator_state = show_indicator_switch.state;
                dbusserver.indicator_state (show_indicator_switch.state);

                if (!show_indicator_switch.active && background_switch.active) {
                    background_switch.active = false;
                }
            });

            preferences_grid.attach (indicator_label, 0, 0, 1, 1);
            preferences_grid.attach (show_indicator_switch, 1, 0, 1, 1);
            preferences_grid.attach (background_label, 0, 1, 1, 1);
            preferences_grid.attach (background_switch, 1, 1, 1, 1);
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

            Timeout.add_seconds (1, () => {
                set_labels ();
            });

            set_labels ();

            int x = settings.window_x;
            int y = settings.window_y;
            if (x != -1 && y != -1) {
                move (x, y);
            }

            this.delete_event.connect (() => {
                    int window_x;
                    int window_y;
                    get_position (out window_x, out window_y);
                    settings.window_x = window_x;
                    settings.window_y = window_y;

                    if (settings.indicator_state == true) {
                        this.hide_on_delete ();
                    } else {
                        dbusserver.indicator_state (false);
                        application.quit ();
                    }
                    return true;
            });
        }

        public bool pomodore_stand_notification () {
            var notification = new GLib.Notification ("Time's up!");
            notification.set_body (_("Go stand and stretch for a while before continuing."));
            var icon = new GLib.ThemedIcon ("appointment");
            notification.set_icon (icon);

            application.send_notification ("com.github.lainsce.niu", notification);
            return true;
        }
        public bool pomodore_drink_notification () {
            var notification = new GLib.Notification ("Time's up!");
            notification.set_body (_("Go drink something before continuing."));
            var icon = new GLib.ThemedIcon ("appointment");
            notification.set_icon (icon);

            application.send_notification ("com.github.lainsce.niu", notification);
            return true;
        }
        public bool pomodore_rest_notification () {
            var notification = new GLib.Notification ("Time's up!");
            notification.set_body (_("Go rest for a while before continuing."));
            var icon = new GLib.ThemedIcon ("appointment");
            notification.set_icon (icon);

            application.send_notification ("com.github.lainsce.niu", notification);
            return true;
        }

        public bool set_labels () {
            var date = new GLib.DateTime.now_local ();
            n_label.set_label (res.get_neralie_time_str (date));
            a_label.set_label (res.get_arvelie_calendar_str (date));
            return true;
        }

        private void set_background_switch_state () {
            background_switch.sensitive = show_indicator_switch.active;

            if (!show_indicator_switch.active) {
                background_switch.state = false;
            }
        }
    }
}
