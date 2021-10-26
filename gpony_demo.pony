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
<span size="xx-large">Pony Gtk4 Demos</span>
GTK Demo is a collection of useful examples to demonstrate GTK widgets and features. It is a useful example in itself.
You can select examples in the sidebar or search for them by typing a search term. Double-clicking or hitting the “Run” button will run the demo. The source code and other resources used in the demo are shown in this area.
You can also use the GTK Inspector, available from the menu on the top right, to poke at the running demos, and see how they are put together.

(Note: Many demos are not implemented yet, nor is the source code inclusion, nor the searching -=- but we're getting there)
                        """

    var i: SGtkTextIter = SGtkTextIter
		var iter: NullablePointer[SGtkTextIter] = NullablePointer[SGtkTextIter](i)
    Gtk4TextBuffer.set_text(appstate.infobuffer, "".cstring(), I32(0))
    Gtk4TextBuffer.get_start_iter(appstate.infobuffer, iter)
    Gtk4TextBuffer.begin_irreversible_action(appstate.infobuffer)
    Gtk4TextBuffer.insert_markup(appstate.infobuffer, iter, descr.cstring(), descr.size().i32())
    Gtk4TextBuffer.end_irreversible_action(appstate.infobuffer)
