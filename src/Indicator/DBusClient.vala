[DBus (name = "com.github.lainsce.niu")]
public interface Niu.DBusClientInterface : Object {
    public abstract void quit_niu () throws GLib.IOError, GLib.DBusError;
    public abstract void show_niu () throws GLib.IOError, GLib.DBusError;
    public signal void update (Utils.Resources data);
    public signal void indicator_state (bool state);
}

public class Niu.DBusClient : Object{
    public DBusClientInterface? interface = null;

    private static GLib.Once<DBusClient> instance;
    public static unowned DBusClient get_default () {
        return instance.once (() => { return new DBusClient (); });
    }

    public signal void niu_vanished ();
    public signal void niu_appeared ();

    construct {
        try {
            interface = Bus.get_proxy_sync (
                BusType.SESSION,
                "com.github.lainsce.niu",
                "/com/github/lainsce/niu"
                );

                Bus.watch_name (
                    BusType.SESSION,
                    "com.github.lainsce.niu",
                    BusNameWatcherFlags.NONE,
                    () => niu_appeared (),
                    () => niu_vanished ()
                );
        } catch (IOError e) {
            error ("Niu Indicator DBus: %s\n", e.message);
        }
    }
}
