class_name Strategy extends ItemData

enum Effect
{
	TEST1,
	TEST2
}

@export var effect : Effect

func apply_strategy():
	match effect:
		Effect.TEST1:
			print("1")
		Effect.TEST2:
			print("2")
