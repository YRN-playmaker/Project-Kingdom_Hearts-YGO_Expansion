-- 维恩图斯χ邦尼塔斯
-- χ刃解放降临
function c100038.initial_effect(c)
	c:EnableReviveLimit()
	
	-- ①：对特召怪兽多次攻击
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetCondition(c100038.exatkcon)
	e1:SetValue(c100038.exatkval)
	c:RegisterEffect(e1)
	
	-- ②：战破送墓→属性数×200伤害
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(100038,0))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F) -- 强制发动
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(aux.bdocon) -- 战斗破坏对方怪兽送墓时
	e2:SetTarget(c100038.damtg)
	e2:SetOperation(c100038.damop)
	c:RegisterEffect(e2)
	
	-- ③：不被非仪式怪兽效果破坏
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c100038.efilter)
	c:RegisterEffect(e3)
end

-- 检查素材：必须使用了 100036 和 100033
function c100038.exatkcon(e)
	local c=e:GetHandler()
	local mg=c:GetMaterial()
	-- 检查是否经过了仪式召唤 (SUMMON_TYPE_RITUAL) 且素材符合
	return c:IsSummonType(SUMMON_TYPE_RITUAL) and mg 
		and mg:IsExists(Card.IsCode,1,nil,100036) 
		and mg:IsExists(Card.IsCode,1,nil,100033)
end

function c100038.exatkval(e,c)
	-- 统计对方场上的特召怪兽
	local g=Duel.GetMatchingGroup(Card.IsSummonType,c:GetControler(),0,LOCATION_MZONE,nil,SUMMON_TYPE_SPECIAL)
	local ct=#g
	if ct>0 then
		return ct-1 -- 如果有怪，返回 N-1 (总共N次)
	else
		return 0	-- 如果没怪，返回 0 (防止返回-1报错)
	end
end

-- ② 计算伤害
function c100038.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	
	-- 统计双方墓地怪兽的属性种类
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,TYPE_MONSTER)
	local attr_sum=0
	local tc=g:GetFirst()
	while tc do
		attr_sum = bit.bor(attr_sum, tc:GetAttribute())
		tc=g:GetNext()
	end
	
	-- 计算有多少种属性
	local count=0
	-- 遍历 0x1(地) 到 0x20(神)，也就是检查7位
	local attributes = {ATTRIBUTE_EARTH, ATTRIBUTE_WATER, ATTRIBUTE_FIRE, ATTRIBUTE_WIND, ATTRIBUTE_LIGHT, ATTRIBUTE_DARK, ATTRIBUTE_DIVINE}
	for _,att in ipairs(attributes) do
		if bit.band(attr_sum, att) ~= 0 then
			count = count + 1
		end
	end
	
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(count*200)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,count*200)
end

function c100038.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end

-- ③ 抗性过滤器
function c100038.efilter(e,re,rp)
	-- 不被“非仪式怪兽”的效果破坏
	-- 注意：魔法陷阱的效果应该可以破坏它吗？
	-- 你的原代码是：rc:IsType(TYPE_MONSTER) and not rc:IsType(TYPE_RITUAL)
	-- 这意味着：魔法/陷阱卡可以破坏它。非仪式怪兽不能破坏它。
	local rc=re:GetHandler()
	return rc:IsType(TYPE_MONSTER) and not rc:IsType(TYPE_RITUAL)
end