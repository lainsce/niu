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
*
*/
namespace Niu {
    public class Application : Gtk.Application {
        public MainWindow? app_window = null;
        private static bool status_background = false;
        private static bool start_in_background = false;
        public string[] args;

        private const GLib.OptionEntry[] cmd_options = {
        // --start-in-background
            { "start-in-background", 'b', 0, OptionArg.NONE, ref start_in_background, "Start in background with wingpanel indicator", null },
            // list terminator
            { null }
        };

        public Application (bool status_indicator) {
            Object (flags: ApplicationFlags.FLAGS_NONE,
            application_id: "com.github.lainsce.niu");
            status_background = status_indicator;
        }

        protected override void activate () {
            var settings = AppSettings.get_default ();
            app_window = new MainWindow (this);
            // only have one window
            if (get_windows () != null) {
                app_window.show_all ();
                app_window.present ();
                return;
            }

            // start in background with indicator
            if (status_background || settings.background_state) {
                if (!settings.indicator_state) {
                    settings.indicator_state = true;
                }

                app_window.hide ();
                settings.background_state = true;
            } else {
                app_window.show_all ();
            }
            app_window.show_all ();
        }

        public static int main (string[] args) {
            Intl.setlocale (LocaleCategory.ALL, "");
            Intl.textdomain (Build.GETTEXT_PACKAGE);

            // add command line options
            try {
                var opt_context = new OptionContext ("");
                opt_context.set_help_enabled (true);
                opt_context.add_main_entries (cmd_options, null);
                opt_context.parse (ref args);
            } catch (OptionError e) {
                print ("Error: %s\n", e.message);
                print ("Run '%s --help' to see a full list of available command line options.\n\n", args[0]);
                return 0;
            }

            var app = new Niu.Application (start_in_background);
            return app.run (args);
        }
    }
}
