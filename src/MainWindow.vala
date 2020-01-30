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

        private uint id1 = 0;
        private uint id2 = 0;
        private uint id3 = 0;

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

            if (settings.pomodoro) {
                set_timeouts ();
            }
            settings.changed.connect (() => {
                if (settings.pomodoro) {
                    set_timeouts ();
                }
            });

            updater.update.connect ((res) => {
                dbusserver.update (res);
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
            var settings = AppSettings.get_default ();
            get_style_context ().add_class ("rounded");
            get_style_context ().add_class ("niu-window");

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

            // Grids
            // info_grid = main overview, shows current Arvelie & Neralie.
            // arve_grid = Arvelie grid, lets you convert a date to Arvelie.
            // nera_grid = Neralie grid, lets you convert a time to Neralie.
            var main_stack = new Gtk.Stack ();
            main_stack.margin = 12;
            var main_stackswitcher = new Gtk.StackSwitcher ();
            main_stackswitcher.stack = main_stack;
            main_stackswitcher.halign = Gtk.Align.CENTER;
            main_stackswitcher.homogeneous = true;
            main_stackswitcher.margin_top = 0;
            var main_stackswitcher_style_context = main_stackswitcher.get_style_context ();
            main_stackswitcher_style_context.add_class (Gtk.STYLE_CLASS_FLAT);
            main_stackswitcher_style_context.add_class ("niu-sts");

            main_stack.add_titled (info_grid (), "informa", (_("Information")));
            main_stack.add_titled (arve_grid (), "arvelie", (_("Arvelie")));
            main_stack.add_titled (nera_grid (), "neralie", (_("Neralie")));

            var main_grid = new Gtk.Grid ();
            main_grid.expand = true;
            main_grid.margin_top = 6;
            main_grid.attach (main_stackswitcher, 0, 0, 1, 1);
            main_grid.attach (main_stack, 0, 1, 1, 1);

            this.add (main_grid);
            this.show_all ();

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

                    if (settings.indicator_state) {
                        this.hide_on_delete ();
                    } else {
                        dbusserver.indicator_state (false);
                        application.quit ();
                    }
                    return true;
            });
        }

        public Gtk.Grid info_grid () {
            //TRANSLATORS: Do not translate "Nataniev Time" as it is a proper name!
            var label = new Gtk.Label (_("In the Nataniev Time system, it is now…"));
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
            //TRANSLATORS: Do not translate "Nataniev Time" as it is a proper name!
            help_button.tooltip_text = _("Learn about Nataniev Time");
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

            var main_grid = new Gtk.Grid ();
            main_grid.orientation = Gtk.Orientation.VERTICAL;
            main_grid.margin = 6;
            main_grid.margin_top = main_grid.margin_bottom = 0;
            main_grid.row_homogeneous = true;
            main_grid.attach (label, 0, 0, 2, 1);
            main_grid.attach (n_label, 0, 1, 2, 1);
            main_grid.attach (help_button, 0, 2);
            main_grid.attach (a_label, 1, 2);

            return main_grid;
        }

        public Gtk.Grid arve_grid () {
            string entry_text = null;
            //TRANSLATORS: Do not translate "Nataniev Time" as it is a proper name!
            var label = new Gtk.Label (_("Convert Date to Arvelie:"));
            label.halign = Gtk.Align.START;
            label.hexpand = true;
            var label_style_context = label.get_style_context ();
            label_style_context.add_class (Granite.STYLE_CLASS_H3_LABEL);
            label_style_context.add_class ("niu-info");

            var a_entry_buffer = new Gtk.EntryBuffer ();
            var a_entry = new Gtk.Entry.with_buffer (a_entry_buffer);
            a_entry.vexpand = false;
            a_entry.hexpand = true;
            a_entry.has_focus = false;
            a_entry.margin_top = 5;
            a_entry.margin_bottom = 5;
            a_entry.placeholder_text = _("Enter date…");

            a_entry.changed.connect (() => {
                if (a_entry.text.length > 0) {
                    a_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "edit-clear-symbolic");
                } else {
                    a_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, null);
                }
            });

            var r_label = new Gtk.Label ("");
            r_label.hexpand = true;
            r_label.halign = Gtk.Align.END;
            var r_label_style_context = r_label.get_style_context ();
            r_label_style_context.add_class (Granite.STYLE_CLASS_H3_LABEL);
            r_label_style_context.add_class ("niu-n");

            a_entry.icon_press.connect ((pos, event) => {
                if (pos == Gtk.EntryIconPosition.SECONDARY) {
                    a_entry.set_text ("");
                    r_label.label = "";
                }
            });

            a_entry_buffer.inserted_text.connect (() => {
                entry_text = a_entry.get_text ();
                var reg = new Regex("(?m)^(?<year>\\d{4})-(?<month>\\d{2})-(?<day>\\d{2})$");
                GLib.MatchInfo match;

                if (reg.match (entry_text, 0, out match)) {
                    var d = new DateTime.local (int.parse(match.fetch_named ("year")), int.parse(match.fetch_named ("month")), int.parse(match.fetch_named ("day")), 0, 0, 0);
                    string ard = res.get_arvelie_calendar_str (d);
                    r_label.label = ard;
                }
            });

            var help_button = new Gtk.Button ();
            help_button.set_image (new Gtk.Image.from_icon_name ("help-contents-symbolic", Gtk.IconSize.SMALL_TOOLBAR));
            help_button.set_always_show_image (true);
            help_button.vexpand = false;
            help_button.tooltip_text = _("A date should be of the format: YYYY-MM-DD.");
            var help_button_style_context = help_button.get_style_context ();
            help_button_style_context.add_class (Gtk.STYLE_CLASS_FLAT);
            help_button_style_context.add_class ("niu-button");
            help_button_style_context.remove_class ("image-button");

            var main_grid = new Gtk.Grid ();
            main_grid.orientation = Gtk.Orientation.VERTICAL;
            main_grid.margin = 6;
            main_grid.margin_top = main_grid.margin_bottom = 0;
            main_grid.row_homogeneous = true;
            main_grid.attach (label, 0, 0, 2, 1);
            main_grid.attach (a_entry, 0, 1, 2, 1);
            main_grid.attach (help_button, 0, 2);
            main_grid.attach (r_label, 1, 2);

            return main_grid;
        }

        public Gtk.Grid nera_grid () {
            string entry_text = null;
            //TRANSLATORS: Do not translate "Nataniev Time" as it is a proper name!
            var label = new Gtk.Label (_("Convert Time to Neralie:"));
            label.halign = Gtk.Align.START;
            label.hexpand = true;
            var label_style_context = label.get_style_context ();
            label_style_context.add_class (Granite.STYLE_CLASS_H3_LABEL);
            label_style_context.add_class ("niu-info");

            var a_entry_buffer = new Gtk.EntryBuffer ();
            var a_entry = new Gtk.Entry.with_buffer (a_entry_buffer);
            a_entry.vexpand = false;
            a_entry.hexpand = true;
            a_entry.has_focus = false;
            a_entry.margin_top = 5;
            a_entry.margin_bottom = 5;
            a_entry.placeholder_text = _("Enter date…");

            a_entry.changed.connect (() => {
                if (a_entry.text.length > 0) {
                    a_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "edit-clear-symbolic");
                } else {
                    a_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, null);
                }
            });

            var r_label = new Gtk.Label ("");
            r_label.hexpand = true;
            r_label.halign = Gtk.Align.END;
            var r_label_style_context = r_label.get_style_context ();
            r_label_style_context.add_class (Granite.STYLE_CLASS_H3_LABEL);
            r_label_style_context.add_class ("niu-n");

            a_entry.icon_press.connect ((pos, event) => {
                if (pos == Gtk.EntryIconPosition.SECONDARY) {
                    a_entry.set_text ("");
                    r_label.label = "";
                }
            });

            a_entry_buffer.inserted_text.connect (() => {
                entry_text = a_entry.get_text ();
                var reg = new Regex("(?m)^(?<hour>\\d{2}):(?<minute>\\d{2}):(?<second>\\d{2})$");
                GLib.MatchInfo match;

                if (reg.match (entry_text, 0, out match)) {
                    var e = new GLib.DateTime.now_local ();
                    var d = new DateTime.local (e.get_year (), e.get_month (), e.get_day_of_month (), int.parse(match.fetch_named ("hour")), int.parse(match.fetch_named ("minute")), int.parse(match.fetch_named ("second")));
                    string ard = res.get_neralie_time_str (d);
                    r_label.label = ard;
                }
            });

            var help_button = new Gtk.Button ();
            help_button.set_image (new Gtk.Image.from_icon_name ("help-contents-symbolic", Gtk.IconSize.SMALL_TOOLBAR));
            help_button.set_always_show_image (true);
            help_button.vexpand = false;
            help_button.tooltip_text = _("A time should be of the format: HH:MM:SS.\nWhere HH is 24-Hour.");
            var help_button_style_context = help_button.get_style_context ();
            help_button_style_context.add_class (Gtk.STYLE_CLASS_FLAT);
            help_button_style_context.add_class ("niu-button");
            help_button_style_context.remove_class ("image-button");

            var main_grid = new Gtk.Grid ();
            main_grid.orientation = Gtk.Orientation.VERTICAL;
            main_grid.margin = 6;
            main_grid.margin_top = main_grid.margin_bottom = 0;
            main_grid.row_homogeneous = true;
            main_grid.attach (label, 0, 0, 2, 1);
            main_grid.attach (a_entry, 0, 1, 2, 1);
            main_grid.attach (help_button, 0, 2);
            main_grid.attach (r_label, 1, 2);

            return main_grid;
        }

        public void set_timeouts () {
            var settings = AppSettings.get_default ();
            if (settings.pomodoro) {
                id1 = Timeout.add_seconds (777, () => {
                    pomodore_rest_notification ();
                    GLib.Source.remove (this.id2);
                    GLib.Source.remove (this.id3);
                    return true;
                });
                id2 = Timeout.add_seconds (1555, () => {
                    pomodore_drink_notification ();
                    GLib.Source.remove (this.id1);
                    GLib.Source.remove (this.id3);
                    return true;
                });
                id3 = Timeout.add_seconds (2332, () => {
                    pomodore_stand_notification ();
                    GLib.Source.remove (this.id2);
                    GLib.Source.remove (this.id1);
                    return true;
                });
            }
        }

        public void pomodore_stand_notification () {
            var notification = new GLib.Notification ("Time's up!");
            notification.set_body (_("Go stand and stretch for a while before continuing."));
            var icon = new GLib.ThemedIcon ("appointment");
            notification.set_icon (icon);

            application.send_notification ("com.github.lainsce.niu", notification);
        }
        public void pomodore_drink_notification () {
            var notification = new GLib.Notification ("Time's up!");
            notification.set_body (_("Go drink something before continuing."));
            var icon = new GLib.ThemedIcon ("appointment");
            notification.set_icon (icon);

            application.send_notification ("com.github.lainsce.niu", notification);
        }
        public void pomodore_rest_notification () {
            var notification = new GLib.Notification ("Time's up!");
            notification.set_body (_("Go rest for a while before continuing."));
            var icon = new GLib.ThemedIcon ("appointment");
            notification.set_icon (icon);

            application.send_notification ("com.github.lainsce.niu", notification);
        }

        public bool set_labels () {
            var settings = AppSettings.get_default ();
            var date = new GLib.DateTime.now_local ();
            if (settings.beats) {
                n_label.set_label (res.get_neralie_beat_str (date));
            } else {
                n_label.set_label (res.get_neralie_time_str (date));
            }
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
