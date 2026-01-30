--键刃-X刃
function c100051.initial_effect(c)
	-- ①：「键刃-X刃」在场上只能有1张表侧表示存在
	-- 参数：范围自己(1)，范围对方(1)，卡号(100051)
	c:SetUniqueOnField(1,1,100051)

	-- 发动效果（装备到对象上）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c100051.target)
	e1:SetOperation(c100051.operation)
	c:RegisterEffect(e1)

	-- 装备限制（必须是“键刃使”仪式怪兽）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c100051.eqlimit)
	c:RegisterEffect(e2)

	-- ②：●攻击表示：攻击力上升
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetCondition(c100051.atkcon)
	e3:SetValue(c100051.atkval)
	c:RegisterEffect(e3)

	-- ②：●守备表示：不会被战斗破坏
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetCondition(c100051.defcon)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end

--------------------------------------------------------------------------------
-- 过滤器与目标选择
--------------------------------------------------------------------------------
function c100051.filter(c)
	-- 0x208 是“键刃使”字段，要求仪式怪兽且表侧
	return c:IsType(TYPE_RITUAL) and c:IsFaceup()
end

-- 系统调用的装备限制检查
function c100051.eqlimit(e,c)
	return c100051.filter(c)
end

function c100051.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c100051.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c100051.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,c100051.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end

function c100051.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Equip(tp,c,tc)
	end
end

--------------------------------------------------------------------------------
-- 效果②：状态判断与数值计算
--------------------------------------------------------------------------------

-- 条件：装备怪兽是攻击表示
function c100051.atkcon(e)
	local tc=e:GetHandler():GetEquipTarget()
	return tc and tc:IsAttackPos()
end

-- 攻击力数值计算
function c100051.atkval(e,c)
	local tp=e:GetHandler():GetControler()
	-- 获取双方墓地的所有怪兽
	local g=Duel.GetMatchingGroup(Card.IsMonster,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	local att=0
	-- 遍历墓地，把所有属性进行“位或”运算
	for tc in aux.Next(g) do
		att = att | tc:GetAttribute()
	end
	
	-- 统计有多少个属性位是 1
	local count=0
	local attributes = {ATTRIBUTE_EARTH, ATTRIBUTE_WATER, ATTRIBUTE_FIRE, ATTRIBUTE_WIND, ATTRIBUTE_LIGHT, ATTRIBUTE_DARK, ATTRIBUTE_DIVINE}
	
	for _,val in ipairs(attributes) do
		if (att & val) ~= 0 then
			count = count + 1
		end
	end
	
	return count * 200
end

-- 条件：装备怪兽是守备表示
function c100051.defcon(e)
	local tc=e:GetHandler():GetEquipTarget()
	return tc and tc:IsDefensePos()
end