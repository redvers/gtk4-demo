use "Gtk"
use "GLib"
use "Gtk4Sys"
use "GLibSys"
use "CairoSys"

use "debug"

primitive AssistantDemo
  fun name(): String => "Assistant"
  fun @callback(appstate: AppState): None =>
    let assistant: NullablePointer[SGtkWidget] = Gtk4Assistant.gnew()
    Gtk4Window.set_default_size(assistant, I32(-1), I32(300))

    AssistantDemo.create_page1(assistant)
    AssistantDemo.create_page2(assistant)
    AssistantDemo.create_page3(assistant)
    AssistantDemo.create_page4(assistant)

    Gtk4Widget.show(assistant)

    GLibSys.g_signal_connect_data[None](assistant, "prepare".cstring(), AssistantDemo~on_assistant_prepare(), None, Pointer[None], I32(0))
    GLibSys.g_signal_connect_data[None](assistant, "cancel".cstring(), AssistantDemo~on_assistant_close_cancel(), None, Pointer[None], I32(0))
    GLibSys.g_signal_connect_data[None](assistant, "close".cstring(), AssistantDemo~on_assistant_close_cancel(), None, Pointer[None], I32(0))
    GLibSys.g_signal_connect_data[None](assistant, "apply".cstring(), AssistantDemo~on_assistant_apply(), None, Pointer[None], I32(0))

  fun @apply_changes_gradually(gw: GWrap): I32 =>
    let page_number: I32 = Gtk4Assistant.get_current_page(gw.obj)
    let current_page: NullablePointer[SGtkWidget] = Gtk4Assistant.get_nth_page(gw.obj, page_number)
    let cnt: F64 = Gtk4ProgressBar.get_fraction(current_page)
    Gtk4ProgressBar.set_fraction(current_page, cnt + 0.05)

    if (cnt < 1) then
      I32(1)
    else
      Gtk4Window.destroy(gw.obj)
      I32(0)
    end


  fun @on_entry_changed(entry: NullablePointer[SGtkWidget], gw: GWrap) =>
    let page_number: I32 = Gtk4Assistant.get_current_page(gw.obj)
    let current_page: NullablePointer[SGtkWidget] = Gtk4Assistant.get_nth_page(gw.obj, page_number)

    if (Gtk4Entry.get_text_length(entry) > U16(0)) then
      Gtk4Assistant.set_page_complete (gw.obj, current_page, I32(1))
    else
      Gtk4Assistant.set_page_complete (gw.obj, current_page, I32(0))
    end

  fun @on_assistant_apply(assistant: NullablePointer[SGtkWidget], data: None) =>
    GLibSys.g_timeout_add[GWrap](U32(100), AssistantDemo~apply_changes_gradually(), GWrap(assistant))

  fun @on_assistant_close_cancel(assistant: NullablePointer[SGtkWidget], data: None) =>
    Gtk4Window.destroy(assistant)


  fun @on_assistant_prepare(assistant: NullablePointer[SGtkWidget], gw: None) =>
    let page_number: I32 = Gtk4Assistant.get_current_page(assistant)
    let n_pages: I32 = Gtk4Assistant.get_n_pages(assistant)

    let title: String = "Sample assistant (" + (page_number + 1).string() + " of " + n_pages.string() + ")"
    Gtk4Window.set_title(assistant, title.cstring())
    if (page_number == 3) then
      Gtk4Assistant.commit(assistant)
    end




  fun create_page1(assistant: NullablePointer[SGtkWidget]) =>
    let gbox: NullablePointer[SGtkWidget] = Gtk4Box.gnew(I32(0), I32(12))
    Gtk4Widget.set_margin_start(gbox, I32(12))
    Gtk4Widget.set_margin_end(gbox, I32(12))
    Gtk4Widget.set_margin_top(gbox, I32(12))
    Gtk4Widget.set_margin_bottom(gbox, I32(12))

    let label: NullablePointer[SGtkWidget] = Gtk4Label.gnew("You must fill out this entry to continue: ".cstring())
    Gtk4Box.append(gbox, label)

    let entry: NullablePointer[SGtkWidget] = Gtk4Entry.gnew()
    Gtk4Entry.set_activates_default(entry, I32(1))
    Gtk4Box.append(gbox, entry)

    // As we can only use pony classes as Generics, we wrap them in GWrap
    // (Of course, this won't be needed in the native PonyAPI
    GLibSys.g_signal_connect_data[GWrap](entry, "changed".cstring(), AssistantDemo~on_entry_changed(), GWrap(assistant), Pointer[None], I32(0))

    Gtk4Widget.set_valign(entry, I32(3)) // GTK_ALIGN_CENTER

    Gtk4Assistant.append_page(assistant, gbox)
    Gtk4Assistant.set_page_title(assistant, gbox, "Page 1".cstring())
    Gtk4Assistant.set_page_type(assistant, gbox, I32(1)) // GTK_ASSISTANT_PAGE_INTRO


  fun create_page2(assistant: NullablePointer[SGtkWidget]) =>
    let gbox: NullablePointer[SGtkWidget] = Gtk4Box.gnew(I32(0), I32(12))
    Gtk4Widget.set_margin_start(gbox, I32(12))
    Gtk4Widget.set_margin_end(gbox, I32(12))
    Gtk4Widget.set_margin_top(gbox, I32(12))
    Gtk4Widget.set_margin_bottom(gbox, I32(12))

    let checkbutton: NullablePointer[SGtkWidget] = Gtk4CheckButton.new_with_label("This is optional data, you may continue ever if you do not check this".cstring())
    Gtk4Widget.set_valign(checkbutton, I32(3)) // GTK_ALIGN_CENTER
    Gtk4Box.append(gbox, checkbutton)

    Gtk4Assistant.append_page(assistant, gbox)
    Gtk4Assistant.set_page_title(assistant, gbox, "Page 2".cstring())
    Gtk4Assistant.set_page_complete(assistant, gbox, I32(1))

  fun create_page3(assistant: NullablePointer[SGtkWidget]) =>
    let label: NullablePointer[SGtkWidget] = Gtk4Label.gnew("This is a confirmation page, press 'Apply' to apply changes".cstring())
    Gtk4Widget.show(label)
    Gtk4Assistant.append_page(assistant, label)
    Gtk4Assistant.set_page_type(assistant, label, I32(2)) // GTK_ASSISTANT_PAGE_CONFIRM
    Gtk4Assistant.set_page_complete(assistant, label, I32(1))
    Gtk4Assistant.set_page_title(assistant, label, "Confirmation".cstring())

  fun create_page4(assistant: NullablePointer[SGtkWidget]) =>
    let progress_bar: NullablePointer[SGtkWidget] = Gtk4ProgressBar.gnew()
    Gtk4Widget.set_halign(progress_bar, I32(0)) // GTK_ALIGN_FILL
    Gtk4Widget.set_valign(progress_bar, I32(3)) // GTK_ALIGN_CENTER
    Gtk4Widget.set_hexpand(progress_bar, I32(1)) // true
    Gtk4Widget.set_margin_start(progress_bar, I32(40))
    Gtk4Widget.set_margin_end(progress_bar, I32(40))
    Gtk4Widget.show(progress_bar)

    Gtk4Assistant.append_page(assistant, progress_bar)
    Gtk4Assistant.set_page_type(assistant, progress_bar, I32(4)) // GTK_ASSISTANT_PAGE_PROGRESS
    Gtk4Assistant.set_page_title(assistant, progress_bar, "Applying changes".cstring())











  fun @selected(appstate: AppState): None =>
    let descr: String = """
                          Demonstrates a sample multi-step assistant with GtkAssistant. Assistants are used to divide an operation into several simpler sequential steps, and to guide the user through these steps.
                        """

    Gtk4TextBuffer.set_text(appstate.infobuffer, descr.cstring(), descr.size().i32())
