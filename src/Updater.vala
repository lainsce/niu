namespace Niu {
    public class Updater : Object {
        private static GLib.Once<Updater> instance;
        private MainWindow? window;
        public static unowned Updater get_default (MainWindow window) {
            return instance.once (() => {
                return new Updater (window);
            });
        }

        private int interval = 1; // in secs

        private Utils.Resources sysres;

        public signal void update (Utils.Resources sysres);

        public Updater (MainWindow window) {
            this.window = window;
        }

        construct {
            Timeout.add_seconds (interval, update_resources);
        }

        private bool update_resources () {
            sysres = Utils.Resources () {
                arvelieneralie = arvelieneralie ()
            };
            update (sysres);
            return true;
        }

        public string arvelieneralie () {
            return window.get_neralie_time_str (window.date) + window.get_arvelie_calendar_str (window.date);
        }
    }
}

