(import eyed3)
(import glob)
(import wx)
(require hyrule [doto])

(setv artist-field None
      album-field None
      title-field None
      current-dialog None
      current-folder-path ""
      current-mp3 None
      row-obj-dict [])

(defn edit-dialog [mp3]
  (global artist-field album-field title-field
          current-dialog current-mp3)
  (let [tag mp3.tag
        dialog-title (str tag.title)
        dlg (wx.Dialog None :title dialog-title)
        main-sizer (wx.BoxSizer wx.VERTICAL)
        artist (wx.TextCtrl dlg :value tag.artist)
        album  (wx.TextCtrl dlg :value tag.album)
        title  (wx.TextCtrl dlg :value tag.title)
        btn-sizer (wx.BoxSizer)
        save-btn   (wx.Button dlg :label "Salvar"   :id wx.ID_OK)
        cancel-btn (wx.Button dlg :label "Cancelar" :id wx.ID_CANCEL)]
    (setv current-mp3 mp3
          dlg.main-sizer main-sizer)
    (add-widgets dlg "Artista" artist)
    (add-widgets dlg "Álbum"   album)
    (add-widgets dlg "Título"  title)
    (setv artist-field artist
          album-field  album
          title-field  title)
    (.Bind save-btn wx.EVT_BUTTON on-save)
    (.Add btn-sizer save-btn   0 wx.ALL 5)
    (.Add btn-sizer cancel-btn 0 wx.ALL 5)
    (.Add main-sizer btn-sizer 0 wx.CENTER)
    (.SetSizer dlg main-sizer)
    (setv current-dialog dlg)))

(defn add-widgets [dlg label-text text-ctrl]
  (let [row-sizer (wx.BoxSizer wx.HORIZONTAL)
        label (wx.StaticText dlg :label label-text :size #(50 -1))]
    (.Add row-sizer label     0 wx.ALL 5)
    (.Add row-sizer text-ctrl 1 (| wx.ALL wx.EXPAND) 5)
    (.Add dlg.main-sizer row-sizer 0 wx.EXPAND)))

(defn on-edit [event]
  (global current-dialog current-folder-path)
  (let [selection (.GetFirstSelected list-ctrl)]
    (if (>= selection 0)
      (let [mp3 (get row-obj-dict selection)]
        (edit-dialog mp3)
        (.ShowModal current-dialog)
        (update-mp3-listing current-folder-path)
        (.Destroy current-dialog))
      (wx.MessageBox "Você precisa selecionar um arquivo primeiro!"
      "Aviso"
      wx.OK frame))))

(defn on-save [event]
  (global current-mp3 current-dialog artist-field album-field title-field)
  (let [tag current-mp3.tag]
    (setv tag.artist (.GetValue artist-field)
          tag.album  (.GetValue album-field)
          tag.title  (.GetValue title-field))
    (.save tag)
    (.Close current-dialog)))

(defn update-mp3-listing [folder-path]
  (global current-folder-path row-obj-dict)
  (setv current-folder-path folder-path
        row-obj-dict [])
  (.ClearAll list-ctrl)
  (.InsertColumn list-ctrl 0 "Artist" :width 140)
  (.InsertColumn list-ctrl 1 "Album"  :width 140)
  (.InsertColumn list-ctrl 2 "Title"  :width 200)
  (.InsertColumn list-ctrl 3 "Year"   :width 200)
  (let [mp3s (glob.glob (+ folder-path "/*.mp3"))]
    (for [[index mp3] (enumerate mp3s)]
      (let [mp3-object (eyed3.load mp3)
            tag mp3-object.tag]
        (.InsertItem list-ctrl index (str tag.artist))
        (.SetItem    list-ctrl index 1 (str tag.album))
        (.SetItem    list-ctrl index 2 (str tag.title))
        (.append row-obj-dict mp3-object)))))

(defn on-open-folder [event]
  (let [dlg (wx.DirDialog frame "Escolha um diretório:" "" wx.DD_DEFAULT_STYLE)]
    (when (= (.ShowModal dlg) wx.ID_OK)
      (update-mp3-listing (.GetPath dlg)))
    (.Destroy dlg)))

(setv app   (wx.App)
      frame (wx.Frame :parent None :title "Editor de Tags MP3" :size #(700 400))
      panel (wx.Panel frame)
      main-sizer  (wx.BoxSizer wx.VERTICAL)
      edit-button (wx.Button panel :label "Editar")
      list-ctrl   (wx.ListCtrl panel
                               :size #(-1 100)
                               :style (| wx.LC_REPORT wx.BORDER_SUNKEN)))

(doto list-ctrl
  (.InsertColumn 0 "Artist" :width 140)
  (.InsertColumn 1 "Album"  :width 140)
  (.InsertColumn 2 "Title"  :width 200))

(setv panel.list-ctrl list-ctrl)
(.Add main-sizer list-ctrl   1 (| wx.ALL wx.EXPAND) 5)
(.Add main-sizer edit-button 0 (| wx.ALL wx.CENTER) 5)
(.SetSizer panel main-sizer)
(.Bind edit-button wx.EVT_BUTTON on-edit)
(.Bind list-ctrl  wx.EVT_LIST_ITEM_ACTIVATED on-edit)

(defn create-menu []
  (let [menu-bar (wx.MenuBar)
        file-menu (wx.Menu)
        open-folder-menu-item (.Append file-menu wx.ID_ANY
                                       "Abrir Pasta"
                                       "Abrir uma pasta com MP3s")]
    (.Append menu-bar file-menu "&Arquivo")
    (.Bind frame wx.EVT_MENU on-open-folder :source open-folder-menu-item)
    (.SetMenuBar frame menu-bar)))

(defn main []
  (create-menu)
  (.Show frame)
  (.MainLoop app))

(main)

