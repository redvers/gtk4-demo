use "Gtk"
use "GLib"
use "Gtk4Sys"
use "GLibSys"
use "CairoSys"

primitive GPonyDemo
  fun name(): String => "GPonyDemo"
  fun @callback(appstate: AppState): None =>
    @printf("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n".cstring())
    @printf("In GPonyDemo callback\n".cstring())

  fun @selected(appstate: AppState): None =>
    let descr: String = """
                          This is a ponylang implementation of the gtk4-demo that comes
                          with Gtk4 which should demonstrate most of the widgets and
                          techniques.
                        """

    Gtk4TextBuffer.set_text(appstate.infobuffer, descr.cstring(), descr.size().i32())
