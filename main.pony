use @g_value_set_string[None](value: NullablePointer[GValue], v_string: Pointer[U8] tag)
use @g_list_store_append[None](store: NullablePointer[GListStore], item: NullablePointer[GObject])
use @g_list_store_new[NullablePointer[GListStore]](item_type: GType)
use @g_simple_action_new[NullablePointer[GSimpleAction]](name: Pointer[U8] tag, parameter_type: NullablePointer[GVariantType])
use @g_action_map_add_action[None](action_map: NullablePointer[GObject] tag, action: NullablePointer[GAction])
use @g_action_map_add_action_entries[None](action_map: NullablePointer[GObject], entries: GPonyAction, n_entries: I32, user_data: Any)
use @printf[I32](fmt: Pointer[U8] tag, ...)
use @g_type_register_static_simple[GType](parent_type: GType, type_name: Pointer[U8] tag, class_size: U32, class_init: Pointer[None], instance_size: U32, instance_init: Pointer[None], GTypeFlags: U32)
use @g_type_register_static[GType](parent_type: GType, type_name: Pointer[U8] tag, info: NullablePointer[GTypeInfo], flags: U32)
use @g_object_get_type[GType]()
use @g_string_get_type[GType]()
use @g_object_new[NullablePointer[GObject]](gtype: GType, property0: Pointer[U8] tag, ...)
use @g_value_init[NullablePointer[GValue]](gvalue: NullablePointer[GValue], gtype: GType)
use @g_object_set[None](gobject: NullablePointer[GObject], pname0: Pointer[U8] tag, ...)
use @g_object_get[None](gobject: NullablePointer[GObject], pname0: Pointer[U8] tag, ...)
use @g_object_class_install_property[None](oclass: NullablePointer[GObjectClass], property_id: U32, pspec: NullablePointer[GParamSpec])
use @g_param_spec_string[NullablePointer[GParamSpec]](name: Pointer[U8] tag, nick: Pointer[U8] tag, blurb: Pointer[U8] tag, default_value: Pointer[U8] tag, flags: U32)
//use @g_pony_get_type[U64]()
//use @g_pony_new[NullablePointer[GPony]]()
//use @foo[None]()


use "Gtk"
use "GLib"
use "Gtk4Sys"
use "GLibSys"
use "CairoSys"
//use "path:."
//use "lib:foo"

use "debug"
use "collections"

actor Main
  new create(env: Env) =>
    /* This MUST be the first call you make. If you try to initiate
     * any Gtk objects before Gtk.init is called - bad things will
     * happen */
    Gtk4Sys.gtk_init()

    /* GResource loads a binary blob from disk which contains all
       the resources that your application uses - like xml files,
       images, etc...  We load it and then register it.

       Once registered - you can just snag it without any pony
       references                                                */
    let resource: GioResource = GioResource.load("demo.gresource")
    resource.register()

    /* This creates your GtkApplication.  AppState is the class
     * that is responsible for building your application and
     * dispatching the callbacks.
     *
     * "me.infect.red" is the application-name given to gnome/dbus */
    var app: GtkApplication = GtkApplication("me.infect.red", 0, AppState)
    app.run()


class AppState is PonyGtkApplication
  /* The activate() callback is called immediately when the application is run.
   * It is used to set up the environment, all the callbacks, and all the
   * things that are needed for your application.
   *
   * Once you return from this function - that is it. You're in the hands of
   * your callbacks only                                               */
  fun ref activate(gtkapp: GtkApplication) =>
	  Debug.out("UI Creation Callback!")
    let builder: GtkBuilder = GtkBuilder.new_from_resource("/ui/main.ui")
    let window: GtkWindow = GtkWindow.create_from_ref(builder.get_object("window"))
    gtkapp.add_window(window)

    var t: GPonyAction = GPonyAction
    var u: GPonyAction = GPonyAction
    var v: GPonyAction = GPonyAction
    t.name = "about".cstring()
		t.func = @{(action: NullablePointer[GSimpleAction], parameter: NullablePointer[GVariant], data: Any): None => @printf("In about fn callback\n".cstring())}
    u.name = "quit".cstring()
		u.func = @{(action: NullablePointer[GSimpleAction], parameter: NullablePointer[GVariant], data: Any): None => @printf("In quit fn callback\n".cstring())}
    v.name = "inspector".cstring()
		v.func = @{(action: NullablePointer[GSimpleAction], parameter: NullablePointer[GVariant], data: Any): None => @printf("In inspector fn callback\n".cstring())}

    @g_action_map_add_action_entries(gtkapp.getobj(), t, I32(1), gtkapp)
    @g_action_map_add_action_entries(gtkapp.getobj(), u, I32(1), gtkapp)
    @g_action_map_add_action_entries(gtkapp.getobj(), v, I32(1), gtkapp)

    let action: NullablePointer[GSimpleAction] = @g_simple_action_new("run".cstring(), NullablePointer[GVariantType].none())
    GLibSys.g_signal_connect_data[AppState](action, "activate".cstring(), @{(gsa: NullablePointer[GSimpleAction], gva: NullablePointer[GVariant], data: AppState): None => data.activate_run()}, this, Pointer[None], I32(0))

    @g_action_map_add_action(window.getobj(), action)

    let notebook: NullablePointer[SGtkWidget] = builder.get_object("notebook")
    let info_view: NullablePointer[SGtkWidget] = builder.get_object("info-textview")
    let source_view: NullablePointer[SGtkWidget] = builder.get_object("source-textview")
    let toplevel: NullablePointer[SGtkWidget] = builder.get_object("window")
    let listview: NullablePointer[SGtkWidget] = builder.get_object("listview")
    GLibSys.g_signal_connect_data[AppState](listview, "activate".cstring(), @{(gsa: NullablePointer[GSimpleAction], gva: NullablePointer[GVariant], data: AppState): None => data.activate_cb()}, this, Pointer[None], I32(0))
    let search_bar: NullablePointer[SGtkWidget] = builder.get_object("searchbar")
    GLibSys.g_signal_connect_data[AppState](search_bar, "notify::search-mode-enabled".cstring(), @{(gsa: NullablePointer[GSimpleAction], gva: NullablePointer[GVariant], data: AppState): None => data.clear_search()}, this, Pointer[None], I32(0))


    var gtypeinfo: GTypeInfo = GTypeInfo
    gtypeinfo.class_size = U16(1216)
    gtypeinfo.class_init = @{(g_class: NullablePointer[GPonyClass], class_data: Pointer[None]): None =>
      @printf("class_init()\n".cstring())
              try
                var gpc: GPonyClass = g_class.apply()?
                gpc.set_property = @{(g_object: GObject, property_id: U32, value: GValue, pspec: GParamSpec): None => @printf("In set_property()\n".cstring())}
                gpc.get_property = @{(g_object: NullablePointer[GPony], property_id: U32, value: NullablePointer[GValue], pspec: NullablePointer[GParamSpec]): None =>
                    @printf("In get_property()\n".cstring())
                    try
                      g_object.apply()?.ponyref.geta(value)
                    end
                }
                @printf("cp: %lu\n".cstring(), gpc.construct_properties)
                @printf("c: %lu\n".cstring(), gpc.constructor)
                @printf("sp: %lu\n".cstring(), gpc.set_property)
                @printf("gp: %lu\n".cstring(), gpc.get_property)
                @printf("d: %lu\n".cstring(), gpc.dispose)
                @printf("f: %lu\n".cstring(), gpc.finalize)
                @printf("dpc: %lu\n".cstring(), gpc.dispatch_properties_changed)
                @printf("n: %lu\n".cstring(), gpc.notify)
                @printf("c: %lu\n".cstring(), gpc.constructed)
                @printf("f: %lu\n".cstring(), gpc.flags)
              end
              let pspec: NullablePointer[GParamSpec] = @g_param_spec_string("name".cstring(), "nick".cstring(), "blurb".cstring(), "default_value".cstring(), U32(3))
              @g_object_class_install_property(g_class, U32(1), pspec)
      }
    gtypeinfo.instance_size = U16(192)
    gtypeinfo.instance_init = @{(instance: NullablePointer[GPony], g_class: NullablePointer[GPonyClass]): None =>
              @printf("instance_init()\n".cstring())
              let p: PonyProperties = PonyProperties
              try
                let i: GPony = instance.apply()?
                i.ponyref = p
                @printf("CheckingPonyInstance: %lu\n".cstring(), i.ponyref)
                @printf("CheckingPonyInstance: %s\n".cstring(), i.title)
              else
                @printf("I aborted in instance_init()\n".cstring())
              end

    }

    let myglibtype: GType = @g_type_register_static(@g_object_get_type(), "GPony".cstring(), NullablePointer[GTypeInfo](gtypeinfo), U32(0))


    let listmodel: NullablePointer[GListStore] = create_demo_model(myglibtype)
    Debug.out("glib value: " + myglibtype.string())

    let treemodel: NullablePointer[SGtkTreeListModel] = Gtk4TreeListModel.gnew(listmodel, I32(0), I32(1), @{(lm: NullablePointer[GListStore]): NullablePointer[GListStore] => NullablePointer[GListStore].none()}, listmodel, Pointer[None])
    // ^^^^ We'll keep the child object a NULL because we're not going to start with a tree ^^^^ //

    var selection: NullablePointer[SGtkSingleSelection] = Gtk4SingleSelection.gnew(treemodel)
    Gtk4ListView.set_model(listview, selection)

    window.show()

	fun create_demo_model(myglibtype: GType): NullablePointer[GListStore] =>
    let store: NullablePointer[GListStore] = @g_list_store_new(myglibtype)
    let d: NullablePointer[GObject] = @g_object_new(myglibtype, Pointer[U8])

    @g_list_store_append(store, d)

    Debug("I DIDN'T SEGV!")
//    @foo()
    store





/*
GtkBuilder *builder;
  GListModel *listmodel;
  GtkTreeListModel *treemodel;
  GSimpleAction *action;

  filter = GTK_FILTER (gtk_custom_filter_new (demo_filter_by_name, filter_model, NULL));
  gtk_filter_list_model_set_filter (filter_model, filter);
  g_object_unref (filter);

  search_entry = GTK_WIDGET (gtk_builder_get_object (builder, "search-entry"));
  g_signal_connect (search_entry, "search-changed", G_CALLBACK (demo_search_changed_cb), filter);

  selection = gtk_single_selection_new (G_LIST_MODEL (filter_model));
  g_signal_connect (selection, "notify::selected-item", G_CALLBACK (selection_cb), NULL);
  gtk_list_view_set_model (GTK_LIST_VIEW (listview), GTK_SELECTION_MODEL (selection));

  selection_cb (selection, NULL, NULL);
  g_object_unref (selection);

  g_object_unref (builder);
*/
		// Ignoring add_main_option for now as it's cli handling.



  fun ref activate_run() =>
		@printf("activate_run()\n".cstring())

  fun ref activate_cb() =>
		@printf("activate_cb()\n".cstring())

  fun ref clear_search() =>
		@printf("clear_search()\n".cstring())



struct GPony
  embed parent_instance: GObject = GObject
  var title: Pointer[U8] = Pointer[U8]
  var ponyref: PonyProperties = PonyProperties.create()

type GPonyClass is GObjectClass

class PonyProperties
  var a: String = "Hello World PonyProperty"

  new create() =>
    @printf("PonyProperties.create()\n".cstring())
    None
    None

  fun ref geta(value: NullablePointer[GValue]) =>
    @g_value_set_string(value, a.cstring())



/*    let myglibtype: GType = @g_type_register_static_simple(
          @g_object_get_type(),
          "appstate".cstring(),
          U32(136),
          @{(g_class: NullablePointer[GPonyClass], class_data: Pointer[None]): None =>
              @printf("In class_init\n".cstring())
              try
                @printf("cp: %lu\n".cstring(), g_class.apply()?.construct_properties)
                @printf("c: %lu\n".cstring(), g_class.apply()?.constructor)
                @printf("sp: %lu\n".cstring(), g_class.apply()?.set_property)
                @printf("gp: %lu\n".cstring(), g_class.apply()?.get_property)
                @printf("d: %lu\n".cstring(), g_class.apply()?.dispose)
                @printf("f: %lu\n".cstring(), g_class.apply()?.finalize)
                @printf("dpc: %lu\n".cstring(), g_class.apply()?.dispatch_properties_changed)
                @printf("n: %lu\n".cstring(), g_class.apply()?.notify)
                @printf("c: %lu\n".cstring(), g_class.apply()?.constructed)
                @printf("f: %lu\n".cstring(), g_class.apply()?.flags)
              end
              let pspec: NullablePointer[GParamSpec] = @g_param_spec_string("name".cstring(), "nick".cstring(), "blurb".cstring(), "default_value".cstring(), U32(3))
              @g_object_class_install_property(g_class, U32(1), pspec)
           },
          U32(136),
          @{(instance: GTypeInstance, g_class: GObjectClass): None =>
            @printf("In instance_init\n".cstring())
           },
          U32(0))
*/
