use "Gtk"
use "GLib"
use "Gtk4Sys"
use "GLibSys"
use "CairoSys"

primitive ApplicationClassDemo
  fun name(): String => "ApplicationClass"
  fun @callback(appstate: AppState): None =>
    @printf("In ApplicationClass callback\n".cstring())

  fun @selected(appstate: AppState): None =>
    let descr: String = """
                          Demonstrates a simple application.
                          This example uses GtkApplication, GtkApplicationWindow, GtkBuilder as well as GMenu and GResource. Due to the way GtkApplication is structured, it is run as a separate process.
                        """

    Gtk4TextBuffer.set_text(appstate.infobuffer, descr.cstring(), descr.size().i32())
