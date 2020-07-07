public class Alohomora.ChangeCipher: Gtk.Dialog {
    public Alohomora.SecretManager secret {get; construct;}

    private Gtk.Grid grid;
    private Gtk.Label warning;
    private Gtk.Label old_key_label;
    private Gtk.Entry old_key;
    private Gtk.Label new_key_label;
    private Gtk.Entry new_key;

    public ChangeCipher (Alohomora.Window app_window, Alohomora.SecretManager secret_manager) {
        Object (
            title: _("Change Cipher Key"),
            transient_for: app_window,
            deletable: false,
            resizable: false,
            modal: true,
            border_width: 10,
            secret: secret_manager
        );
    }

    construct {
        warning = new Gtk.Label (_("CHANGING THE CIPHER KEY WILL MAKE THE EXISTING SECRETS UNUSABLE"));
        warning.get_style_context ().add_class ("message-warning");
        warning.halign = Gtk.Align.CENTER;
        old_key_label = new Gtk.Label (_("Old Cipher Key:"));
        old_key_label.halign = Gtk.Align.START;
        old_key = new Gtk.Entry ();
        old_key.visibility = false;
        old_key.secondary_icon_name = "image-red-eye-symbolic";
        old_key.secondary_icon_tooltip_text = _("Show Old Cipher Key");
        old_key.icon_press.connect (() => old_key.visibility = !old_key.visibility);
        new_key_label = new Gtk.Label (_("New Cipher Key:"));
        new_key_label.halign = Gtk.Align.START;
        new_key = new Gtk.Entry();
        new_key.visibility = false;
        new_key.secondary_icon_name = "image-red-eye-symbolic";
        new_key.secondary_icon_tooltip_text = _("Show New Cipher Key");
        new_key.icon_press.connect (() => new_key.visibility = !new_key.visibility);
        new_key.activate.connect (() => secret.change_cipher_key.begin(GLib.Environment.get_real_name(), old_key.text, new_key.text));

        grid = new Gtk.Grid ();
        grid.column_spacing = 5;
        grid.row_spacing = 5;
        grid.margin = 15;
        grid.attach (warning,       0, 0, 3, 1);
        grid.attach (old_key_label, 0, 1, 1, 1);
        grid.attach (old_key,       1, 1, 2, 1);
        grid.attach (new_key_label, 0, 2, 1, 1);
        grid.attach (new_key,       1, 2, 2, 1);

        get_content_area ().pack_start (grid);
        get_content_area ().show_all ();

        add_button (_("Cancel"), Gtk.ResponseType.CLOSE);
        var add = add_button (_("Change Key"), Gtk.ResponseType.APPLY);
        add.get_style_context ().add_class ("discouraged-button");

        response.connect(id => {
            if(id == Gtk.ResponseType.CLOSE) {
                destroy ();
            }
            else if (id == Gtk.ResponseType.APPLY) {
                if(old_key.text != "" && new_key.text != "") {
                    secret.change_cipher_key.begin(GLib.Environment.get_real_name(), old_key.text, new_key.text);
                }
            }
        });

        secret.key_changed.connect((is_changed) => {
            if(is_changed) {
                destroy();
            }
        });
    }
}