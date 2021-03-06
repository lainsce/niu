namespace Niu {
    public class Updater : Object {
        private static GLib.Once<Updater> instance;
        public static unowned Updater get_default () {
            return instance.once (() => {
                return new Updater ();
            });
        }

        private int interval = 1; // in secs

        private Utils.Resources res;

        public signal void update (Utils.Resources res);

        construct {
            Timeout.add_seconds (interval, update_resources);
        }

        private bool update_resources () {
            res = Utils.Resources () {
                ar = ar (),
                ne = ne (),
                po = po (),
                bt = bt ()
            };
            update (res);
            return true;
        }

        public bool po () {
            return res.get_pomodoro_state ();
        }

        public string ne () {
            var date = new GLib.DateTime.now ();
            return res.get_neralie_time_str (date);
        }

        public string ar () {
            var date = new GLib.DateTime.now ();
            return res.get_arvelie_calendar_str (date);
        }

        public string bt () {
            var date = new GLib.DateTime.now ();
            return res.get_neralie_beat_str (date);
        }
    }
}
