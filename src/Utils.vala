namespace Niu.Utils {
    public struct Resources {
        public string ar;
        public string ne;
        public double va;
        public bool po;

        public bool get_pomodoro_state () {
            var settings = AppSettings.get_default ();
            if (settings.pomodoro) {
                po = true;
            } else {
                po = false;
            }
            return po;
        }

        public string get_arvelie_calendar_str (GLib.DateTime date) {
            string resm = "";
            double resd;
            string m = "";
            string d = "";
            var doty = double.parse(date.format ("%j"));
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
                resd = (doty % 14);
                if (resd < 10) {
                    d = "0" + resd.to_string ();
                } else {
                    d = resd.to_string ();
                }
            }
            var arvelie = "%s%s%s".printf (y, m, d);
            return arvelie;
        }

        public string get_neralie_time_str (GLib.DateTime date) {
            double e = date.to_unix ();
            double d = new DateTime.local (date.get_year (), date.get_month (), date.get_day_of_month (), 0, 0, 0).to_unix ();
            va = ((e - d) / 8640 / 10000) / 10000;
            string val_fmt = (va * 10000000).to_string ();

            var neralie = "%s:%s".printf(val_fmt.substring(2, 3), val_fmt.substring(5, 3));
            return neralie;
        }
    }
}
