extends Node

const SHOP_ITEM_SCENE := preload("res://scenes/map/shop_item.tscn")

# world.
@onready var world: Control = %World
@onready var background: Sprite2D = %Background
@onready var stage_selects: Control = %StageSelects

# shop.
@onready var shop: Control = %Shop
@onready var shop_item_list: GridContainer = %ShopItemList
# selected.
@onready var selected_shop_item: VBoxContainer = %SelectedShopItem
@onready var select_icon: TextureRect = %SelectIcon
@onready var select_id: Label = %SelectID
@onready var select_description: Label = %SelectDescription
@onready var buy_button: Button = %BuyButton

# paper.
@onready var paper_label: Label = %PaperLabel

# focused item.
var shop_focused_item : ShopItem

func _ready():
	# init.
	GameManager.load_game()
	GameManager.set_ui_focus_mode()
	
	# get loaded datas.
	paper_label.text = str(GameManager.paper)
	
	# view manage.
	shop.hide()
	selected_shop_item.hide()
	
	# stage set up.
	background.frame = GameManager.game_progress
	
	var i := 0
	for select : Button in stage_selects.get_children():
		select.pressed.connect(stage_selected.bind(i))
		select.visible = (i <= GameManager.game_progress)
		i += 1
	
	# shop set up.
	for item_data : ItemData in Pool.shop_item_pool:
		var shop_item := SHOP_ITEM_SCENE.instantiate()
		shop_item.data = item_data
		# not unlock, or sold out.
		shop_item.disabled = (item_data.unlock_stage > GameManager.game_progress)\
			or GameManager.purchased_items.has(item_data)
		shop_item.pressed.connect(show_shop_item_info.bind(shop_item))
		shop_item_list.add_child(shop_item)

# stage selects.
func stage_selected(index : int):
	GameManager.stage_data = Pool.stage_pool[index]
	SceneManager.change_scene(SceneManager.GameScene.OPERATION)

func enter_shop():
	world.hide()
	shop.show()

func exit_shop():
	world.show()
	shop.hide()

func show_shop_item_info(shop_item : ShopItem):
	shop_focused_item = shop_item
	
	select_icon.texture = shop_item.data.sprite
	select_id.text = shop_item.data.id
	#select_description.text = shop_item.data.description
	
	buy_button.disabled = (shop_item.data.shop_cost > GameManager.paper)
	selected_shop_item.show()

func purchase_item():
	GameManager.paper -= shop_focused_item.data.shop_cost
	paper_label.text = str(GameManager.paper)
	
	GameManager.purchased_items.append(shop_focused_item.data)
	
	# sold out.
	shop_focused_item.disabled = true
	selected_shop_item.hide()
