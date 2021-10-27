use "Gtk"
use "GLib"
use "Gtk4Sys"
use "GLibSys"
use "CairoSys"

use "debug"

use @g_simple_action_group_new[NullablePointer[GSimpleActionGroup]]()
use @g_action_get_name[Pointer[U8]](gaction: NullablePointer[GObject])

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

    let actions: NullablePointer[GSimpleActionGroup] = @g_simple_action_group_new()
    let actionnames: Array[String] = ["new"; "open"; "save"; "save-as"; "copy"; "cut"; "paste"; "quit"; "about"; "help"]
    for f in actionnames.values() do
      let s: GActionEntry = GActionEntry
      s.name = f.cstring()
      s.activate = @{(action: NullablePointer[GSimpleAction], parameter: NullablePointer[GVariant], data: Any): None =>
        let ss: Pointer[U8] = @g_action_get_name(action)
        @printf("Callback not implemented for %s\n".cstring(), ss)}
      @g_action_map_add_action_entries(actions, s, I32(1), None)
    end
    Gtk4Widget.insert_action_group(window.getobj(), "win".cstring(), actions)
