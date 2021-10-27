use "Gtk"
use "GLib"
use "Gtk4Sys"
use "GLibSys"
use "CairoSys"

use "debug"

primitive BuilderDemo
  // Name of the demo as displayed in the menu
  fun name(): String => "BuilderDemo"

  // Function called to populate the Info Window
  fun @selected(appstate: AppState): None =>
    let descr: String = """
                          Demonstrates a traditional interface, loaded from a XML description, and shows how to connect actions to the menu items and toolbar buttons.
                        """
    Gtk4TextBuffer.set_text(appstate.infobuffer, descr.cstring(), descr.size().i32())


  // Function called to actually *START* the demo
  fun @callback(appstate: AppState): None =>
    let builder: GtkBuilder = GtkBuilder.new_from_resource("/builder/demo.ui")
    let window: GtkWindow = GtkWindow.create_from_ref(builder.get_object("window1"))
      window.show()
