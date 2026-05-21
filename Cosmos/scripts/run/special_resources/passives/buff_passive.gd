class_name BuffPassive extends Passive

@export var buff : Buff

func effect(own_unit : Unit):
	own_unit.affect_buff(buff.create_refind_buff(own_unit.get_all_unsigned_stat()))
